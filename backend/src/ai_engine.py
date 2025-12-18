import os
import shutil
import gc
import json
import random
from typing import List, Dict, Any

# Import librerie AI
from langchain_community.document_loaders import PyPDFLoader
from langchain_text_splitters import RecursiveCharacterTextSplitter
from langchain_huggingface import HuggingFaceEmbeddings 
from langchain_community.vectorstores import FAISS  # <--- CAMBIO QUI
from langchain_ollama import ChatOllama
from langchain_core.prompts import ChatPromptTemplate
from langchain_core.output_parsers import StrOutputParser

# Import funzionanti nel tuo ambiente
from langchain_classic.chains.retrieval import create_retrieval_chain
from langchain_classic.chains.combine_documents import create_stuff_documents_chain

# Import locali
from .models import AVAILABLE_MODELS, QuizRequest
from .utils import clean_json_output

# Import locali
from .models import AVAILABLE_MODELS, QuizRequest
from .utils import clean_json_output

# Costanti
DB_DIR = "vector_db_faiss" 
UPLOAD_DIR = "uploaded_files"

class AIEngine:
    def __init__(self):
        self.llm = None
        self.current_model_id = "pro"
        self.jobs = {} 
        self.load_llm(self.current_model_id)

    def load_llm(self, model_id: str):
        config = AVAILABLE_MODELS.get(model_id, AVAILABLE_MODELS["pro"])
        print(f"[AI] Connecting to Ollama: {config['id']}...")
        try:
            self.llm = ChatOllama(model=config["id"], temperature=0.3, num_ctx=4096)
            self.current_model_id = model_id
            return True
        except Exception as e:
            print(f"[AI Error] Connection failed: {e}")
            return False

    # --- 1. GESTIONE DATABASE ---
    def rebuild_db(self):
        gc.collect()
        if os.path.exists(DB_DIR):
            try: shutil.rmtree(DB_DIR)
            except: pass
            
        if not os.path.exists(UPLOAD_DIR): os.makedirs(UPLOAD_DIR)
        files = [f for f in os.listdir(UPLOAD_DIR) if f.endswith('.pdf')]
        
        if not files: return 0

        all_docs = []
        for f in files:
            path = os.path.join(UPLOAD_DIR, f)
            try:
                loader = PyPDFLoader(path)
                docs = loader.load()
                for d in docs: d.metadata['source'] = f 
                all_docs.extend(docs)
            except Exception as e:
                print(f"[Error] Failed loading {f}: {e}")

        if not all_docs: return 0

        text_splitter = RecursiveCharacterTextSplitter(chunk_size=800, chunk_overlap=100)
        splits = text_splitter.split_documents(all_docs)
        embeddings = HuggingFaceEmbeddings(model_name="all-MiniLM-L6-v2")
        
        try:
            vector_db = FAISS.from_documents(splits, embeddings)
            vector_db.save_local(DB_DIR)
            print(f"[DB] Database ricostruito con {len(files)} file.")
            return len(files)
        except Exception as e:
            print(f"[DB Error] {e}")
            return 0

    def get_vector_db(self):
        embeddings = HuggingFaceEmbeddings(model_name="all-MiniLM-L6-v2")
        if os.path.exists(DB_DIR):
            try:
                return FAISS.load_local(DB_DIR, embeddings, allow_dangerous_deserialization=True)
            except: return None
        return None

    # --- 2. CHAT CON DOCUMENTI (RAG) ---
    def get_chat_response(self, question: str):
        vector_db = self.get_vector_db()
        if not vector_db: return "Carica un PDF per iniziare a chattare."
        
        retriever = vector_db.as_retriever(search_kwargs={'k': 4})
        docs = retriever.invoke(question)
        context_text = "\n\n".join([d.page_content for d in docs])

        prompt = ChatPromptTemplate.from_template("""
        Sei un assistente di studio esperto. Rispondi alla domanda basandoti SOLO sul contesto fornito.
        Se la risposta non è nel contesto, dillo chiaramente.
        
        CONTESTO:
        {context}
        
        DOMANDA: {input}
        """)
        
        chain = prompt | self.llm | StrOutputParser()
        return chain.invoke({"context": context_text, "input": question})

    # --- 3. VALUTAZIONE RISPOSTE (GRADING) ---
    def grade_answer(self, question: str, correct_answer: str, user_answer: str, lang: str):
        prompt_text = """
        Sei un professore universitario. Valuta la risposta dello studente.
        
        DOMANDA: {q}
        RIFERIMENTO CORRETTO: {ref}
        RISPOSTA STUDENTE: {user}
        
        Compito:
        1. Assegna un voto da 0 a 100.
        2. "feedback": Scrivi un commento critico sull'errore o sulla correttezza.
        3. "ideal_answer": Scrivi la versione perfetta e sintetica della risposta corretta.
        
        Rispondi ESCLUSIVAMENTE con questo formato JSON:
        {{
            "score": 85,
            "feedback": "Il concetto è giusto ma manca...",
            "ideal_answer": "La definizione formale corretta è..."
        }}
        """
        prompt = ChatPromptTemplate.from_template(prompt_text)
        chain = prompt | self.llm | StrOutputParser()
        
        try:
            res = chain.invoke({
                "q": question, "ref": correct_answer, "user": user_answer, "lang": lang
            })
            return json.loads(clean_json_output(res))
        except Exception as e:
            print(f"[Grade Error] {e}")
            # Fallback in caso di errore
            return {
                "score": 0, 
                "feedback": "Errore durante la valutazione.", 
                "ideal_answer": correct_answer
            }

    # --- 4. RIGENERAZIONE DOMANDA ---
    # --- AGGIUNGI QUESTO METODO ALLA CLASSE AIEngine ---
    def regenerate_question(self, original_text: str, instruction: str, lang: str):
        prompt_template = """
        Sei un esaminatore esperto. Modifica la domanda seguendo l'istruzione.
        
        DOMANDA ORIGINALE: {q}
        ISTRUZIONE UTENTE: {instr}
        LINGUA OUTPUT: {lang}
        
        Rispondi SOLO con un JSON valido:
        {{
            "domanda": "Nuovo testo...",
            "tipo": "multipla" (o "aperta"),
            "opzioni": ["A)...", "B)..."], (se multipla)
            "corretta": "...",
            "source_file": "AI Regenerated"
        }}
        """
        
        try:
            prompt = ChatPromptTemplate.from_template(prompt_template)
            chain = prompt | self.llm | StrOutputParser()
            
            response = chain.invoke({
                "q": original_text,
                "instr": instruction,
                "lang": lang
            })
            
            clean_json = clean_json_output(response)
            data = json.loads(clean_json)
            
            # Mappiamo i dati per il frontend
            return {
                "questionText": data.get("domanda", ""),
                "type": data.get("tipo", "aperta"),
                "options": data.get("opzioni", []) if data.get("tipo") == "multipla" else [],
                "correctAnswer": data.get("corretta", ""),
                "sourceFile": "AI Regenerated",
                "isLocked": False  # Sblocchiamo la domanda così puoi rispondere di nuovo
            }
            
        except Exception as e:
            print(f"[Regen Error] {e}")
            return None
        
    # --- 5. GENERAZIONE QUIZ ---
    def generate_quiz_task(self, job_id: str, request: QuizRequest):
        try:
            self.jobs[job_id]["status"] = "processing"
            
            vector_db = self.get_vector_db()
            if not vector_db:
                raise Exception("Database non trovato. Carica prima un PDF.")

            # --- LOGICA DI RECUPERO ---
            # FAISS supporta MMR proprio come Chroma
            retriever = vector_db.as_retriever(
                search_type="mmr", 
                search_kwargs={'k': max(40, request.num_questions * 3), 'lambda_mult': 0.5}
            )
            
            # Se prompt vuoto, cerca concetti base
            query = request.custom_prompt if len(request.custom_prompt) > 2 else "concetti fondamentali riassunto"
            all_retrieved_docs = retriever.invoke(query)
            
            # Shuffle richiesto
            random.shuffle(all_retrieved_docs)
            
            # --- PLANNING ---
            total_needed = request.num_questions
            if request.question_type == "open":
                open_needed = total_needed
                mc_needed = 0
            elif request.question_type == "multiple":
                open_needed = 0
                mc_needed = total_needed
            else: # mixed
                open_needed = total_needed // 5 
                mc_needed = total_needed - open_needed

            remaining_open = open_needed
            remaining_total = total_needed
            
            prompt_template = """
            Sei un esaminatore tecnico esperto.
            
            ISTRUZIONI UTENTE:
            - Lingua output: {lang} (IMPORTANTE: Traduci tutto il contenuto in {lang})
            - Focus/Stile: {custom_prompt}
            
            FONTI:
            {context_slice}
            
            COMPITO BATCH:
            Genera:
            - {num_mc} domande a Risposta Multipla (Max {max_opt} opzioni).
            - {num_open} domande a Risposta Aperta.

            REGOLE:
            1. IGNORA info amministrative, date, nomi docenti, link, email.
            2. Estrai "source_file" dall'intestazione [File: ...] del testo.
            3. Rispondi ESCLUSIVAMENTE in JSON valido.
            
            FORMATO JSON ({lang}):
            {{
                "questions": [
                    {{ 
                        "domanda": "...", 
                        "tipo": "multipla", 
                        "opzioni": ["A)...", "B)..."], 
                        "corretta": "A)...",
                        "source_file": "nome_esatto_file.pdf"
                    }},
                    {{ 
                        "domanda": "...", 
                        "tipo": "aperta",
                        "source_file": "nome_esatto_file.pdf"
                    }}
                ]
            }}
            Evita duplicati di: {history_topics}
            """
            
            all_questions = []
            generated_hashes = [] 
            BATCH_SIZE = 5
            num_batches_needed = (remaining_total // BATCH_SIZE) + 1
            chunks_per_batch = max(2, len(all_retrieved_docs) // num_batches_needed) if num_batches_needed > 0 else 2
            
            current_doc_index = 0
            attempts_fail = 0

            while remaining_total > 0 and attempts_fail < 5:
                current_batch_size = min(BATCH_SIZE, remaining_total)
                
                batch_open_count = 0
                if remaining_open > 0:
                    batch_open_count = 1 if current_batch_size < 3 else 2
                    batch_open_count = min(batch_open_count, remaining_open)
                    remaining_open -= batch_open_count
                
                batch_mc_count = current_batch_size - batch_open_count
                
                end_index = current_doc_index + chunks_per_batch
                slice_docs = all_retrieved_docs[current_doc_index : end_index]
                if not slice_docs:
                    slice_docs = all_retrieved_docs[:chunks_per_batch]
                    random.shuffle(all_retrieved_docs)
                    
                context_slice_text = "\n\n".join([f"[File: {d.metadata.get('source', 'Unknown')}]\n{d.page_content}" for d in slice_docs])
                
                batch_sources = [d.metadata.get('source', 'Unknown') for d in slice_docs]
                unique_sources = list(set(batch_sources))
                fallback_source = unique_sources[0] if len(unique_sources) == 1 else "Multiple Sources"
                
                current_doc_index += chunks_per_batch
                if current_doc_index >= len(all_retrieved_docs):
                    current_doc_index = 0
                    
                history_topics = "Nessuno"
                if generated_hashes:
                    history_topics = ", ".join([h[:15]+"..." for h in generated_hashes[-10:]])

                try:
                    prompt = ChatPromptTemplate.from_template(prompt_template)
                    chain = prompt | self.llm
                    
                    response = chain.invoke({
                        "context_slice": context_slice_text,
                        "num_mc": batch_mc_count,
                        "num_open": batch_open_count,
                        "max_opt": request.max_options,
                        "history_topics": history_topics,
                        "lang": request.language,
                        "custom_prompt": request.custom_prompt
                    })
                    
                    clean_json = clean_json_output(response.content if hasattr(response, 'content') else str(response))
                    data = json.loads(clean_json)
                    new_qs = data.get("questions", [])
                    
                    valid_batch = []
                    for q in new_qs:
                        q_text = q.get('domanda', '').strip()
                        q_type = q.get('tipo', 'multipla')
                        
                        s_file = q.get('source_file', '').strip()
                        if not s_file or s_file.lower() == "unknown":
                            q['source_file'] = fallback_source
                        
                        if q_type == 'multipla':
                            opts = q.get('opzioni', [])
                            if len(opts) > request.max_options:
                                q['opzioni'] = opts[:request.max_options]
                        else:
                            q.pop("opzioni", None)

                        if q_text and q_text not in generated_hashes:
                            valid_batch.append(q)
                            generated_hashes.append(q_text)
                    
                    if valid_batch:
                        all_questions.extend(valid_batch)
                        remaining_total -= len(valid_batch)
                        attempts_fail = 0
                        self.jobs[job_id]["progress"] = len(all_questions)
                    else:
                        if batch_open_count > 0: remaining_open += batch_open_count 
                        attempts_fail += 1
                        
                except Exception as e:
                    print(f"[WARN] Batch issue in job {job_id}: {e}")
                    if batch_open_count > 0: remaining_open += batch_open_count 
                    attempts_fail += 1

            del vector_db
            gc.collect()

            self.jobs[job_id]["result"] = all_questions
            self.jobs[job_id]["status"] = "completed"
            
        except Exception as e:
            print(f"[ERROR] Job {job_id} failed: {e}")
            self.jobs[job_id]["status"] = "failed"
            self.jobs[job_id]["error"] = str(e)

engine = AIEngine()