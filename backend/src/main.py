from fastapi import FastAPI, UploadFile, File, BackgroundTasks, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import os
import shutil
import uuid

# Import engine
from .ai_engine import engine
from .models import QuizRequest

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

UPLOAD_DIR = "uploaded_files"

# --- MODELLI DATI PER REQUEST ---
class ChatRequest(BaseModel):
    question: str

class GradeRequest(BaseModel):
    question: str
    correct_answer: str
    user_answer: str
    language: str

class RegenRequest(BaseModel):
    question_text: str
    instruction: str
    language: str

# --- ENDPOINTS ---

@app.get("/system/status")
def status():
    files = os.listdir(UPLOAD_DIR) if os.path.exists(UPLOAD_DIR) else []
    return {
        "status": "online",
        "model": engine.current_model_id,
        "files": [f for f in files if f.endswith(".pdf")],
        "models": [{"id": "llama3.1", "name": "Llama 3.1 Pro", "active": True}]
    }

@app.post("/files/upload")
async def upload_pdf(file: UploadFile = File(...)):
    if not os.path.exists(UPLOAD_DIR): os.makedirs(UPLOAD_DIR)
    path = os.path.join(UPLOAD_DIR, file.filename)
    with open(path, "wb") as buffer:
        shutil.copyfileobj(file.file, buffer)
    
    # Ricostruisce il DB subito dopo l'upload
    count = engine.rebuild_db()
    return {"status": "ok", "indexed_files": count}

@app.delete("/files/delete/{filename}")
def delete_file(filename: str):
    path = os.path.join(UPLOAD_DIR, filename)
    if os.path.exists(path):
        os.remove(path)
        engine.rebuild_db()
        return {"status": "deleted"}
    return {"status": "error"}

@app.delete("/files/clear_all")
def clear_all():
    if os.path.exists(UPLOAD_DIR):
        shutil.rmtree(UPLOAD_DIR)
        os.makedirs(UPLOAD_DIR)
    engine.rebuild_db()
    return {"status": "cleared"}

# --- ENDPOINT GENERAZIONE ---
@app.post("/quiz/start_generation")
def start_gen(req: QuizRequest, background_tasks: BackgroundTasks):
    job_id = str(uuid.uuid4())
    engine.jobs[job_id] = {"status": "pending", "progress": 0, "total": req.num_questions}
    background_tasks.add_task(engine.generate_quiz_task, job_id, req)
    return {"job_id": job_id}

@app.get("/quiz/status/{job_id}")
def get_status(job_id: str):
    return engine.jobs.get(job_id, {"status": "not_found"})

# --- NUOVI ENDPOINT (Chat, Grade, Regen) ---

@app.post("/chat")
def chat_endpoint(req: ChatRequest):
    """Endpoint per chattare col PDF"""
    answer = engine.get_chat_response(req.question)
    return {"answer": answer}

@app.post("/quiz/grade")
def grade_endpoint(req: GradeRequest):
    """Valuta risposta aperta"""
    result = engine.grade_answer(req.question, req.correct_answer, req.user_answer, req.language)
    return result

@app.post("/quiz/regenerate_single")
def regen_endpoint(req: RegenRequest):
    """Rigenera una singola domanda"""
    new_question = engine.regenerate_question(req.question_text, req.instruction, req.language)
    if not new_question:
        raise HTTPException(status_code=500, detail="Generation failed")
    return new_question