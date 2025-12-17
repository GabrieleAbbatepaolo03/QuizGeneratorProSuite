from pydantic import BaseModel
from typing import List, Optional, Any

# --- CONFIGURAZIONE MODELLI OLLAMA ---
AVAILABLE_MODELS = {
    "eco": {"id": "llama3.2:1b", "name": "Eco (1B)", "compatible": True},
    "balanced": {"id": "llama3.2:3b", "name": "Balanced (3B)", "compatible": True},
    "pro": {"id": "llama3.1", "name": "Pro (8B)", "compatible": True}
}

# --- SCHEMI DI RICHIESTA (REQUESTS) ---

class ChatRequest(BaseModel):
    question: str

class QuizRequest(BaseModel):
    num_questions: int
    custom_prompt: str 
    language: str
    question_type: str = "mixed" # mixed, open, multiple
    max_options: int = 4

class GradeRequest(BaseModel):
    question: str
    correct_answer: str
    user_answer: str
    language: str

class RegenerateRequest(BaseModel):
    question_text: str
    instruction: str
    language: str