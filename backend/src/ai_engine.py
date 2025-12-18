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
from langchain_community.vectorstores import FAISS 
from langchain_ollama import ChatOllama
from langchain_core.prompts import ChatPromptTemplate
from langchain_core.output_parsers import StrOutputParser

# Import funzionanti nel tuo ambiente
from langchain_classic.chains.retrieval import create_retrieval_chain
from langchain_classic.chains.combine_documents import create_stuff_documents_chain

# Import locali
from .models import AVAILABLE_MODELS, QuizRequest
from .utils import clean_json_output

# Costanti
DB_DIR = "vector_db_ctx" 
LIBRARY_DIR = "document_library"

class AIEngine:
    def __init__(self):
        self.llm = None
        self.current_model_id = "pro"
        self.jobs = {} 
        self.active_files = [] 
        self.load_llm(self.current_model_id)
        
        if not os.path.exists(LIBRARY_DIR):
            os.makedirs(LIBRARY_DIR)

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

    # --- RICOSTRUZIONE SU RICHIESTA (PATH A) ---
    def load_context(self, filenames: List[str]):
        if set(filenames) == set(self.active_files) and self.get_vector_db() is not None:
            print("[AI] Contesto già attivo. Skip reload.")
            return len(filenames)

        print(f"[AI] Caricamento contesto per: {filenames}")
        gc.collect()
        
        if os.path.exists(DB_DIR):
            try: shutil.rmtree(DB_DIR)
            except: pass
            
        all_docs = []
        loaded_files = []

        for f_name in filenames:
            path = os.path.join(LIBRARY_DIR, f_name)
            if not os.path.exists(path):
                print(f"[WARN] File non trovato in archivio: {f_name}")
                continue
                
            try:
                loader = PyPDFLoader(path)
                docs = loader.load()
                for d in docs: 
                    d.metadata['source'] = f_name 
                all_docs.extend(docs)
                loaded_files.append(f_name)
            except Exception as e:
                print(f"[Error] Failed loading {f_name}: {e}")

        if not all_docs:
            self.active_files = []
            return 0

        text_splitter = RecursiveCharacterTextSplitter(chunk_size=800, chunk_overlap=100)
        splits = text_splitter.split_documents(all_docs)
        embeddings = HuggingFaceEmbeddings(model_name="all-MiniLM-L6-v2")
        
        try:
            vector_db = FAISS.from_documents(splits, embeddings)
            vector_db.save_local(DB_DIR)
            self.active_files = loaded_files
            print(f"[DB] Database rigenerato con {len(loaded_files)} file.")
            return len(loaded_files)
        except Exception as e:
            print(f"[DB Error] {e}")
            self.active_files = []
            return 0

    def get_vector_db(self):
        embeddings = HuggingFaceEmbeddings(model_name="all-MiniLM-L6-v2")
        if os.path.exists(DB_DIR):
            try:
                return FAISS.load_local(DB_DIR, embeddings, allow_dangerous_deserialization=True)
            except: return None
        return None

    def get_chat_response(self, question: str):
        vector_db = self.get_vector_db()
        if not vector_db: return "Carica un PDF per iniziare a chattare."
        
        retriever = vector_db.as_retriever(search_kwargs={'k': 4})
        docs = retriever.invoke(question)
        context_text = "\n\n".join([d.page_content for d in docs])

        # PROMPT CHAT (ENGLISH)
        prompt = ChatPromptTemplate.from_template("""
        You are an expert study assistant. Answer the question based ONLY on the provided context.
        If the answer is not in the context, state it clearly.
        
        CONTEXT:
        {context}
        
        QUESTION: {input}
        
        IMPORTANT: Answer in the same language as the question.
        """)
        
        chain = prompt | self.llm | StrOutputParser()
        return chain.invoke({"context": context_text, "input": question})

    def grade_answer(self, question: str, correct_answer: str, user_answer: str, lang: str):
        # PROMPT GRADING (ENGLISH)
        prompt_text = """
        You are a strict university professor. Grade the student's answer.
        
        QUESTION: {q}
        REFERENCE ANSWER: {ref}
        STUDENT ANSWER: {user}
        
        TASK:
        1. Assign a score from 0 to 100.
        2. "feedback": Write a critical comment on mistakes or correctness in {lang}.
        3. "ideal_answer": Write the perfect, synthetic correct answer in {lang}.
        
        RESPOND ONLY IN THIS JSON FORMAT:
        {{
            "score": 85,
            "feedback": "The concept is correct but...",
            "ideal_answer": "The formal definition is..."
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
            return {"score": 0, "feedback": "Evaluation error.", "ideal_answer": correct_answer}

    def regenerate_question(self, original_text: str, instruction: str, lang: str):
        # PROMPT REGENERATE (ENGLISH)
        prompt_template = """
        You are an expert examiner. Modify the question following the instruction.
        
        ORIGINAL QUESTION: {q}
        USER INSTRUCTION: {instr}
        OUTPUT LANGUAGE: {lang}
        
        RESPOND ONLY WITH VALID JSON:
        {{
            "domanda": "New question text...",
            "tipo": "multipla" (or "aperta"),
            "opzioni": ["A)...", "B)..."], (only if multiple)
            "corretta": "Correct answer...",
            "source_file": "AI Regenerated"
        }}
        """
        try:
            prompt = ChatPromptTemplate.from_template(prompt_template)
            chain = prompt | self.llm | StrOutputParser()
            response = chain.invoke({"q": original_text, "instr": instruction, "lang": lang})
            data = json.loads(clean_json_output(response))
            return {
                "questionText": data.get("domanda", ""),
                "type": data.get("tipo", "aperta"),
                "options": data.get("opzioni", []) if data.get("tipo") == "multipla" else [],
                "correctAnswer": data.get("corretta", ""),
                "sourceFile": "AI Regenerated",
                "isLocked": False 
            }
        except Exception as e:
            return None

    # --- 5. GENERAZIONE QUIZ (CORE) ---
    def generate_quiz_task(self, job_id: str, request: QuizRequest):
        try:
            self.jobs[job_id]["status"] = "processing"
            
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
            # -----------------------------------------------

            vector_db = self.get_vector_db()
            if not vector_db:
                raise Exception("Database not found. Load a PDF first.")

            # --- RETRIEVAL ---
            retriever = vector_db.as_retriever(
                search_type="mmr", 
                search_kwargs={'k': max(40, request.num_questions * 3), 'lambda_mult': 0.5}
            )
            
            query = request.custom_prompt if len(request.custom_prompt) > 2 else "main concepts summary definitions"
            all_retrieved_docs = retriever.invoke(query)
            
            random.shuffle(all_retrieved_docs)
            
            # PROMPT GENERAZIONE (ENGLISH - OPTIMIZED)
            prompt_template = """
            You are an expert technical examiner.
            
            USER INSTRUCTIONS:
            - OUTPUT LANGUAGE: {lang} (CRITICAL: Translate all content to {lang})
            - TOPIC/STYLE: {custom_prompt}
            
            SOURCE CONTEXT:
            {context_slice}
            
            TASK:
            Generate a quiz based ONLY on the context above.
            - {num_mc} Multiple Choice Questions (Max {max_opt} options).
            - {num_open} Open-Ended Questions.
            
            IMPORTANT RULES:
            1. If {num_mc} is 0, DO NOT generate multiple choice questions.
            2. If {num_open} is 0, DO NOT generate open-ended questions.
            3. IGNORE administrative info (dates, emails, author names).
            4. Extract "source_file" from the text header [File: ...].
            
            REQUIRED JSON FORMAT ({lang}):
            {{
                "questions": [
                    {{ 
                        "domanda": "Question text...", 
                        "tipo": "multipla", 
                        "opzioni": ["A) Correct", "B) Wrong"], 
                        "corretta": "A) Correct",
                        "source_file": "exact_filename.pdf"
                    }},
                    {{ 
                        "domanda": "Open question text...", 
                        "tipo": "aperta",
                        "corretta": "Synthetic ideal answer...",
                        "source_file": "exact_filename.pdf"
                    }}
                ]
            }}
            Avoid duplicates of: {history_topics}
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
                    
                history_topics = "None"
                if generated_hashes:
                    history_topics = ", ".join([h[:15]+"..." for h in generated_hashes[-10:]])

                try:
                    prompt = ChatPromptTemplate.from_template(prompt_template)
                    chain = prompt | self.llm | StrOutputParser()
                    
                    response = chain.invoke({
                        "context_slice": context_slice_text,
                        "num_mc": batch_mc_count,
                        "num_open": batch_open_count,
                        "max_opt": request.max_options,
                        "history_topics": history_topics,
                        "lang": request.language,
                        "custom_prompt": request.custom_prompt
                    })
                    
                    clean_json = clean_json_output(response)
                    data = json.loads(clean_json)
                    new_qs = data.get("questions", [])
                    
                    valid_batch = []
                    for q in new_qs:
                        q_text = q.get('domanda', '').strip()
                        q_type = q.get('tipo', 'multipla').lower()
                        
                        # --- FILTRO SICUREZZA ---
                        if request.question_type == "open" and q_type != "aperta":
                            continue
                        if request.question_type == "multiple" and q_type != "multipla":
                            continue
                        
                        # --- FIX OPZIONI ---
                        if q_type == 'multipla':
                            opts = q.get('opzioni', [])
                            if not opts:
                                if request.question_type == "multiple":
                                    continue 
                                else:
                                    q['tipo'] = 'aperta'
                                    q_type = 'aperta'
                            elif len(opts) > request.max_options:
                                q['opzioni'] = opts[:request.max_options]
                        else:
                            q.pop("opzioni", None)

                        s_file = q.get('source_file', '').strip()
                        if not s_file or s_file.lower() == "unknown":
                            q['source_file'] = fallback_source
                        
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