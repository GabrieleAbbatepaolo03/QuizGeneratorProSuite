from fastapi import FastAPI, UploadFile, File, BackgroundTasks, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import List
import os
import shutil
import uuid

from .ai_engine import engine, LIBRARY_DIR
from .models import QuizRequest

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

# --- MODELLI ---
class ContextRequest(BaseModel):
    filenames: List[str]

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

# --- ENDPOINTS SISTEMA ---

@app.get("/system/status")
def status():
    # Ritorna la lista di TUTTI i file nell'archivio
    files = os.listdir(LIBRARY_DIR) if os.path.exists(LIBRARY_DIR) else []
    return {
        "status": "online",
        "model": engine.current_model_id,
        "files": [f for f in files if f.endswith(".pdf")], # Archivio completo
        "active_context": engine.active_files, # Cosa c'è caricato ORA in memoria
        "models": [{"id": "llama3.1", "name": "Llama 3.1 Pro", "active": True}]
    }

@app.post("/system/load-context")
def load_context_endpoint(req: ContextRequest):
    """
    Endpoint cruciale per PATH A.
    Riceve lista file -> Ricostruisce il DB al volo.
    """
    count = engine.load_context(req.filenames)
    return {"status": "ok", "loaded_files": count}

# --- GESTIONE FILE (ARCHIVIO) ---

@app.post("/files/upload")
async def upload_pdf(file: UploadFile = File(...)):
    if not os.path.exists(LIBRARY_DIR): os.makedirs(LIBRARY_DIR)
    
    path = os.path.join(LIBRARY_DIR, file.filename)
    
    # CHECK DUPLICATI: Se esiste, rifiuta
    if os.path.exists(path):
        raise HTTPException(status_code=409, detail="File already exists in library")
        
    with open(path, "wb") as buffer:
        shutil.copyfileobj(file.file, buffer)
    
    # Nota: Non ricostruiamo il DB qui automaticamente. 
    # Lo farà l'utente selezionando il file e premendo "Generate" o aprendo un quiz.
    return {"status": "ok", "filename": file.filename}

@app.delete("/files/delete/{filename}")
def delete_file(filename: str):
    path = os.path.join(LIBRARY_DIR, filename)
    if os.path.exists(path):
        os.remove(path)
        # Se cancello un file che era attivo nel contesto, pulisco il contesto per sicurezza
        if filename in engine.active_files:
            engine.active_files = [] 
        return {"status": "deleted"}
    return {"status": "error"}

# --- ENDPOINTS QUIZ & AI (Invariati) ---
# ... (Copia pure grade, chat, regen e start_generation dal tuo file precedente) ...
# ... Sono identici, ma assicurati che siano presenti ...

@app.post("/quiz/grade")
def grade_endpoint(req: GradeRequest):
    result = engine.grade_answer(req.question, req.correct_answer, req.user_answer, req.language)
    return result

@app.post("/chat")
def chat_endpoint(req: ChatRequest):
    answer = engine.get_chat_response(req.question)
    return {"answer": answer}

@app.post("/quiz/regenerate_single")
def regen_endpoint(req: RegenRequest):
    new_question = engine.regenerate_question(req.question_text, req.instruction, req.language)
    if not new_question: raise HTTPException(status_code=500, detail="Gen failed")
    return new_question

@app.post("/quiz/start_generation")
def start_gen(req: QuizRequest, background_tasks: BackgroundTasks):
    job_id = str(uuid.uuid4())
    engine.jobs[job_id] = {"status": "pending", "progress": 0, "total": req.num_questions}
    # NOTA: generate_quiz_task userà il DB corrente (quello caricato con load-context)
    background_tasks.add_task(engine.generate_quiz_task, job_id, req)
    return {"job_id": job_id}

@app.get("/quiz/status/{job_id}")
def get_status(job_id: str):
    return engine.jobs.get(job_id, {"status": "not_found"})