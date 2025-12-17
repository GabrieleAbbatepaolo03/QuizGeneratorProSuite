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

# Import funzionanti nel tuo ambiente
from langchain_classic.chains.retrieval import create_retrieval_chain
from langchain_classic.chains.combine_documents import create_stuff_documents_chain

# Import locali
from .models import AVAILABLE_MODELS, QuizRequest
from .utils import clean_json_output

# Costanti
DB_DIR = "vector_db_faiss" # Cambiamo nome cartella per pulizia
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
            self.llm = ChatOllama(model=config["id"], temperature=0.4, num_ctx=4096)
            self.current_model_id = model_id
            return True
        except Exception as e:
            print(f"[AI Error] Connection failed: {e}")
            return False

    def rebuild_db(self):
        """Legge i PDF e crea il database vettoriale FAISS"""
        gc.collect()
        
        # Pulisci vecchia cartella
        if os.path.exists(DB_DIR):
            try: shutil.rmtree(DB_DIR)
            except: pass
            
        if not os.path.exists(UPLOAD_DIR): os.makedirs(UPLOAD_DIR)
        files = [f for f in os.listdir(UPLOAD_DIR) if f.endswith('.pdf')]
        
        if not files:
            print("[DB] Nessun file PDF trovato.")
            return 0

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
        
        # Embeddings
        embeddings = HuggingFaceEmbeddings(model_name="all-MiniLM-L6-v2")
        
        # CREAZIONE FAISS
        print("[DB] Creazione indice FAISS...")
        try:
            vector_db = FAISS.from_documents(splits, embeddings)
            vector_db.save_local(DB_DIR) # Salvataggio su disco
            print(f"[DB] Database ricostruito con {len(files)} file.")
            return len(files)
        except Exception as e:
            print(f"[DB Error] {e}")
            return 0

    def get_vector_db(self):
        """Helper per caricare il DB se esiste"""
        embeddings = HuggingFaceEmbeddings(model_name="all-MiniLM-L6-v2")
        if os.path.exists(DB_DIR):
            try:
                # allow_dangerous_deserialization è necessario per file locali fidati
                return FAISS.load_local(DB_DIR, embeddings, allow_dangerous_deserialization=True)
            except Exception as e:
                print(f"[DB Load Error] {e}")
                return None
        return None

    def get_chat_response(self, question: str):
        vector_db = self.get_vector_db()
        if not vector_db: return "Nessuna conoscenza caricata. Carica un PDF prima."
        
        retriever = vector_db.as_retriever(search_kwargs={'k': 4})
        
        prompt = ChatPromptTemplate.from_template(
            "Sei un assistente di studio. Usa SOLO il seguente contesto per rispondere.\n<context>{context}</context>\nDomanda: {input}"
        )
        
        chain = create_retrieval_chain(retriever, create_stuff_documents_chain(self.llm, prompt))
        res = chain.invoke({"input": question})
        return res["answer"]

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