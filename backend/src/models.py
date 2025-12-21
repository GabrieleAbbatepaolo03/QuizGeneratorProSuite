from pydantic import BaseModel, Field, field_validator
from typing import List, Optional, Any, Union

# --- CONFIGURAZIONE MODELLI OLLAMA ---
AVAILABLE_MODELS = {
    "balanced": {
        "id": "qwen2.5:14b", 
        "name": "Qwen 2.5 (14B) - Best Builder", 
        "compatible": True,
        "description": "Perfetto per generare, verificare e tradurre."
    },
    "max_logic": {
        "id": "gemma2:27b", 
        "name": "Gemma 2 (27B) - The Architect", 
        "compatible": True,
        "description": "Lento ma profondissimo. Ideale per l'analisi iniziale."
    },
    "fast": {
        "id": "llama3.1", 
        "name": "Llama 3.1 (8B) - Fast", 
        "compatible": True,
        "description": "Velocissimo, ma meno preciso in Italiano."
    }
}

# --- SCHEMI AI (OUTPUT PARSING) ---

class AIQuestion(BaseModel):
    # Rinominiamo i campi in inglese
    question: str = Field(description="The question text.")
    type: str = Field(description="Type: 'multiple_choice' or 'open_ended'.")
    options: List[Union[str, dict]] = Field(description="List of options.", default=[]) 
    answer: Union[str, int, float] = Field(description="The correct answer.")
    explanation: Optional[str] = Field(description="Concise explanation.", default="")

    # --- VALIDATORE TIPO: Forza lo standard Inglese ---
    @field_validator('type', mode='before')
    @classmethod
    def normalize_type(cls, v):
        s = str(v).lower().strip()
        # Mappa qualsiasi input (es. "Scelta Multipla", "Multi") allo standard
        if any(k in s for k in ['multi', 'choice', 'select', 'scelta']):
            return 'multiple_choice'
        return 'open_ended'

    # --- VALIDATORI OPZIONI E RISPOSTA (Standardizzati) ---
    @field_validator('options', mode='before')
    @classmethod
    def normalize_options(cls, v):
        if not v: return []
        cleaned = []
        for opt in v:
            if isinstance(opt, dict):
                val = opt.get('text') or opt.get('value') or list(opt.values())[0]
                cleaned.append(str(val))
            else:
                cleaned.append(str(opt))
        return cleaned

    @field_validator('answer', mode='before')
    @classmethod
    def normalize_correct(cls, v):
        return str(v)

class AIQuizOutput(BaseModel):
    questions: List[AIQuestion] = Field(description="Lista delle domande.", alias="domande")

# --- SCHEMI REQUEST ---

class ChatRequest(BaseModel):
    question: str
    model_id: str = "balanced"
    language: str = "en" 

class QuizRequest(BaseModel):
    num_questions: int
    custom_prompt: str 
    language: str
    question_type: str = "mixed" 
    max_options: int = 4
    model_id: str = "balanced"

class GradeRequest(BaseModel):
    question: str
    correct_answer: str
    user_answer: str
    language: str

class RegenerateRequest(BaseModel):
    question_text: str
    instruction: str
    language: str