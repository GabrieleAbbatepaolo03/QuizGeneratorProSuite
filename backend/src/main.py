import logging
from fastapi import FastAPI, UploadFile, File, BackgroundTasks, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import List
import os
import shutil
import uuid

# Importa AVAILABLE_MODELS per leggere la configurazione reale
from .ai_engine import engine, LIBRARY_DIR
from .models import QuizRequest, AVAILABLE_MODELS, ChatRequest, GradeRequest, RegenerateRequest

# --- LOGGING FILTER CONFIGURATION ---
# Questa classe filtra i log di Uvicorn per nascondere le richieste di polling fastidiose
class EndpointFilter(logging.Filter):
    def filter(self, record: logging.LogRecord) -> bool:
        # Nascondi i log che contengono questo path
        return record.getMessage().find("/quiz/status/") == -1

# Applichiamo il filtro al logger di accesso di uvicorn
logging.getLogger("uvicorn.access").addFilter(EndpointFilter())

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

# --- MODELLI DI RICHIESTA AGGIUNTIVI ---
class ContextRequest(BaseModel):
    filenames: List[str]

# --- ENDPOINTS SISTEMA ---

@app.get("/system/status")
def status():
    """
    Ritorna lo stato del sistema, costruendo la lista modelli dinamicamente
    da models.py invece che averla hardcoded.
    """
    files = os.listdir(LIBRARY_DIR) if os.path.exists(LIBRARY_DIR) else []
    
    # Costruzione dinamica della lista modelli per il frontend
    model_list = []
    for key, config in AVAILABLE_MODELS.items():
        model_list.append({
            "id": key,             # Es: "balanced"
            "name": config["name"],# Es: "Qwen 2.5 (14B)..."
            "active": (key == engine.current_model_id) # True se è quello in uso
        })

    return {
        "status": "online",
        "model": engine.current_model_id,
        "files": [f for f in files if f.endswith(".pdf")],
        "active_context": engine.active_files,
        "models": model_list # Ora invia la lista vera
    }

@app.post("/system/switch-model/{model_id}")
def switch_model_endpoint(model_id: str):
    """
    Endpoint mancante richiesto dal frontend per cambiare modello.
    """
    if model_id not in AVAILABLE_MODELS:
        raise HTTPException(status_code=404, detail="Model ID not found")
    
    success = engine.load_llm(model_id)
    if not success:
        raise HTTPException(status_code=500, detail="Failed to load model in Ollama")
        
    return {"status": "ok", "current_model": engine.current_model_id}

@app.post("/system/load-context")
def load_context_endpoint(req: ContextRequest):
    count = engine.load_context(req.filenames)
    return {"status": "ok", "loaded_files": count}

# --- GESTIONE FILE (ARCHIVIO) ---

@app.post("/files/upload")
async def upload_pdf(file: UploadFile = File(...)):
    if not os.path.exists(LIBRARY_DIR): os.makedirs(LIBRARY_DIR)
    
    path = os.path.join(LIBRARY_DIR, file.filename)
    if os.path.exists(path):
        raise HTTPException(status_code=409, detail="File already exists in library")
        
    with open(path, "wb") as buffer:
        shutil.copyfileobj(file.file, buffer)
    
    return {"status": "ok", "filename": file.filename}

@app.delete("/files/delete/{filename}")
def delete_file(filename: str):
    path = os.path.join(LIBRARY_DIR, filename)
    if os.path.exists(path):
        os.remove(path)
        if filename in engine.active_files:
            engine.active_files = [] 
        return {"status": "deleted"}
    return {"status": "error"}

@app.delete("/files/clear_all")
def clear_all_files():
    try:
        if os.path.exists(LIBRARY_DIR):
            for filename in os.listdir(LIBRARY_DIR):
                file_path = os.path.join(LIBRARY_DIR, filename)
                try:
                    if os.path.isfile(file_path) or os.path.islink(file_path):
                        os.unlink(file_path)
                    elif os.path.isdir(file_path):
                        shutil.rmtree(file_path)
                except Exception as e:
                    print(f'Failed to delete {file_path}. Reason: {e}')
        engine.active_files = [] # Reset context
        return {"status": "cleared"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# --- ENDPOINTS QUIZ & AI ---

@app.post("/quiz/grade")
def grade_endpoint(req: GradeRequest):
    result = engine.grade_answer(req.question, req.correct_answer, req.user_answer, req.language)
    return result

@app.post("/chat")
def chat_endpoint(req: ChatRequest):
    answer = engine.get_chat_response(req.question, req.language)
    return {"answer": answer}

@app.post("/quiz/regenerate_single")
def regen_endpoint(req: RegenerateRequest):
    new_question = engine.regenerate_question(req.question_text, req.instruction, req.language)
    if not new_question: raise HTTPException(status_code=500, detail="Gen failed")
    return new_question

@app.post("/quiz/start_generation")
def start_gen(req: QuizRequest, background_tasks: BackgroundTasks):
    job_id = str(uuid.uuid4())
    engine.jobs[job_id] = {"status": "pending", "progress": 0, "total": req.num_questions}
    background_tasks.add_task(engine.generate_quiz_task, job_id, req)
    return {"job_id": job_id}

@app.get("/quiz/status/{job_id}")
def get_status(job_id: str):
    return engine.jobs.get(job_id, {"status": "not_found"})

@app.post("/quiz/stop/{job_id}")
def stop_gen(job_id: str):
    if job_id in engine.jobs:
        engine.jobs[job_id]["status"] = "cancelled"
        return {"status": "cancelled"}
    raise HTTPException(status_code=404, detail="Job not found")