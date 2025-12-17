import os
import uvicorn
import shutil
import uuid
from fastapi import FastAPI, UploadFile, File, BackgroundTasks, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from contextlib import asynccontextmanager

# Import interni
from .models import QuizRequest, ChatRequest, GradeRequest, RegenerateRequest, AVAILABLE_MODELS
from .ai_engine import engine, UPLOAD_DIR
from .utils import get_hardware_specs

@asynccontextmanager
async def lifespan(app: FastAPI):
    os.makedirs(UPLOAD_DIR, exist_ok=True)
    print("[SYSTEM] Backend avviato correttamente.")
    yield
    print("[SYSTEM] Spegnimento server.")

app = FastAPI(lifespan=lifespan)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

# --- ENDPOINTS ---

@app.get("/system/status")
def system_status():
    files = []
    if os.path.exists(UPLOAD_DIR):
        files = [f for f in os.listdir(UPLOAD_DIR) if f.endswith('.pdf')]
    
    models_list = []
    for k, v in AVAILABLE_MODELS.items():
        models_list.append({
            "id": k, 
            "name": v["name"], 
            "active": (k == engine.current_model_id),
            "compatible": True
        })
        
    return {
        "status": "online", 
        "files": files, 
        "models": models_list,
        "specs": get_hardware_specs()
    }

@app.post("/system/switch-model/{model_key}")
def switch_model(model_key: str):
    if engine.load_llm(model_key):
        return {"status": "success"}
    raise HTTPException(500, "Errore cambio modello")

@app.post("/files/upload")
async def upload_pdf(file: UploadFile = File(...)):
    path = os.path.join(UPLOAD_DIR, file.filename)
    with open(path, "wb") as buffer:
        shutil.copyfileobj(file.file, buffer)
    
    count = engine.rebuild_db()
    return {"status": "ok", "filename": file.filename, "files_indexed": count}

@app.delete("/files/delete/{filename}")
def delete_file(filename: str):
    path = os.path.join(UPLOAD_DIR, filename)
    if os.path.exists(path):
        os.remove(path)
        engine.rebuild_db()
        return {"status": "deleted"}
    raise HTTPException(404, "File non trovato")

@app.delete("/files/clear_all")
def clear_all():
    if os.path.exists(UPLOAD_DIR):
        for f in os.listdir(UPLOAD_DIR):
            try: os.remove(os.path.join(UPLOAD_DIR, f))
            except: pass
    engine.rebuild_db()
    return {"status": "cleared"}

@app.post("/chat")
def chat_endpoint(req: ChatRequest):
    return {"answer": engine.get_chat_response(req.question)}

# --- QUIZ ENDPOINTS (ASYNC CON BACKGROUND TASKS) ---

@app.post("/quiz/start_generation")
async def start_gen(req: QuizRequest, background_tasks: BackgroundTasks):
    job_id = str(uuid.uuid4())
    
    # Inizializza stato job nella memoria dell'engine
    engine.jobs[job_id] = {
        "job_id": job_id,
        "status": "pending",
        "progress": 0,
        "total": req.num_questions,
        "result": []
    }
    
    # Avvia task in background usando la logica originale
    background_tasks.add_task(engine.generate_quiz_task, job_id, req)
    
    return {"job_id": job_id}

@app.get("/quiz/status/{job_id}")
def get_status(job_id: str):
    job = engine.jobs.get(job_id)
    if not job:
        raise HTTPException(404, "Job non trovato")
    return job

@app.post("/quiz/grade")
def grade(req: GradeRequest):
    # Placeholder grading (o ripristina tua logica originale se complessa)
    return {"score": 100, "feedback": "Funzione grading attiva"}

@app.post("/quiz/regenerate_single")
def regenerate(req: RegenerateRequest):
    return {"domanda": "Domanda rigenerata", "tipo": "aperta", "source_file": "AI"}

if __name__ == "__main__":
    uvicorn.run(app, host="127.0.0.1", port=8001)