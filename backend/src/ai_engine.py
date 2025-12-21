import os
import shutil
import gc
import json
import requests
import math
import time 
import random 
from typing import List

# Import AI
from langchain_community.document_loaders import PyPDFLoader
from langchain_text_splitters import RecursiveCharacterTextSplitter
from langchain_huggingface import HuggingFaceEmbeddings 
from langchain_community.vectorstores import FAISS 
from langchain_ollama import ChatOllama
from langchain_core.prompts import ChatPromptTemplate
from langchain_core.output_parsers import StrOutputParser, PydanticOutputParser

# Import Locali
from .models import AVAILABLE_MODELS, QuizRequest, AIQuizOutput, AIQuestion
from .utils import clean_json_output

DB_DIR = "vector_db_ctx" 
LIBRARY_DIR = "document_library"

class AIEngine:
    def __init__(self):
        self.llm = None
        self.current_model_id = "default"
        self.jobs = {} 
        self.active_files = [] 
        self.load_llm("balanced") 
        if not os.path.exists(LIBRARY_DIR): os.makedirs(LIBRARY_DIR)

    def _check_ollama_model_exists(self, model_name: str) -> bool:
        try:
            res = requests.get("http://localhost:11434/api/tags")
            if res.status_code == 200:
                models = [m['name'] for m in res.json().get('models', [])]
                return any(model_name in m for m in models)
        except: pass
        return True 

    def load_llm(self, model_key: str):
        config = AVAILABLE_MODELS.get(model_key, AVAILABLE_MODELS.get("balanced"))
        if not config: config = list(AVAILABLE_MODELS.values())[0]

        if self.current_model_id == model_key and self.llm is not None: return True

        print(f"🔌 [SYSTEM] Switching Model to: {config['name']}...")
        try:
            self.llm = None
            gc.collect()
            ctx_size = 4096 if "27b" in config["id"] else 8192 
            self.llm = ChatOllama(model=config["id"], temperature=0.1, num_ctx=ctx_size) 
            self.current_model_id = model_key
            print(f"   ✅ Model Loaded. VRAM Context: {ctx_size}")
            return True
        except Exception as e:
            print(f"   ❌ Connection failed: {e}")
            if model_key != "balanced":
                print("   ⚠️ Fallback to Balanced model.")
                return self.load_llm("balanced")
            return False

    def load_context(self, filenames: List[str]):
        if set(filenames) == set(self.active_files) and self.get_vector_db() is not None:
            return len(filenames)

        print(f"📂 [SYSTEM] Indexing {len(filenames)} files: {filenames}")
        gc.collect() 
        if os.path.exists(DB_DIR):
            try: shutil.rmtree(DB_DIR)
            except: pass
            
        all_docs = []
        loaded_files = []
        for f_name in filenames:
            path = os.path.join(LIBRARY_DIR, f_name)
            if not os.path.exists(path): continue
            try:
                loader = PyPDFLoader(path)
                docs = loader.load()
                for d in docs: d.metadata['source'] = f_name 
                all_docs.extend(docs)
                loaded_files.append(f_name)
            except Exception as e:
                print(f"   ❌ Error loading {f_name}: {e}")

        if not all_docs: return 0
        text_splitter = RecursiveCharacterTextSplitter(chunk_size=1200, chunk_overlap=200)
        splits = text_splitter.split_documents(all_docs)
        embeddings = HuggingFaceEmbeddings(model_name="all-MiniLM-L6-v2")
        try:
            vector_db = FAISS.from_documents(splits, embeddings)
            vector_db.save_local(DB_DIR)
            self.active_files = loaded_files
            print(f"   ✅ Index created: {len(splits)} chunks.")
            return len(loaded_files)
        except Exception as e:
            print(f"   ❌ DB Error: {e}")
            return 0

    def get_vector_db(self):
        embeddings = HuggingFaceEmbeddings(model_name="all-MiniLM-L6-v2")
        if os.path.exists(DB_DIR):
            try: return FAISS.load_local(DB_DIR, embeddings, allow_dangerous_deserialization=True)
            except: return None
        return None

    def _is_cancelled(self, job_id: str) -> bool:
        if job_id in self.jobs and self.jobs[job_id].get("status") == "cancelled":
            print(f"⛔ Job {job_id[:8]} detected as CANCELLED. Aborting task.")
            return True
        return False

    def extract_key_topics(self, vector_db, num_topics: int, lang: str) -> List[str]:
        print(f"🏗️  [ARCHITECT] Analyzing document structure for {num_topics} micro-topics...")
        
        retriever = vector_db.as_retriever(search_kwargs={'k': 25}) 
        docs = retriever.invoke("Table of contents hierarchy structure chapter summary glossary definitions")
        context = "\n".join([d.page_content[:1500] for d in docs])
        
        prompt_text = """
        Role: Information Architect. 
        Task: Extract a comprehensive list of {num} DISTINCT, SPECIFIC micro-topics or concepts.
        Context: The user wants to generate a quiz with high variety. Avoid generic chapter titles. 
        Focus on specific algorithms, definitions, events, or formulas found in the text.
        
        Output format: A simple comma-separated list in {lang}. NO numbering. NO introductory text.
        TEXT PREVIEW: {context}
        """
        prompt = ChatPromptTemplate.from_template(prompt_text)
        chain = prompt | self.llm | StrOutputParser()
        
        try:
            res = chain.invoke({"num": num_topics, "context": context, "lang": lang})
            raw_list = res.replace('\n', ',').split(',')
            topics = []
            for t in raw_list:
                clean_t = t.strip()
                if (clean_t and len(clean_t) > 3 and 
                    not clean_t.endswith(':') and 
                    "here is" not in clean_t.lower()):
                    topics.append(clean_t)
            
            seen = set()
            unique_topics = [x for x in topics if not (x in seen or seen.add(x))]
            return unique_topics[:num_topics]
            
        except Exception:
            return ["General Concepts", "Details", "Analysis"]

    def generate_quiz_task(self, job_id: str, request: QuizRequest):
        job_start_time = time.time()

        if self._is_cancelled(job_id): return
        
        print(f"\n{'='*60}")
        print(f"🚀 STARTING QUIZ GENERATION | ID: {job_id[:8]}...")
        print(f"🎯 Target: {request.num_questions} Questions")
        print(f"{'='*60}")
        
        try:
            # --- START ARCHITECT PHASE ---
            self.jobs[job_id]["status"] = "processing"
            self.jobs[job_id]["phase"] = "Extracting Topics (Architect)..." # AGGIORNAMENTO FASE
            
            vector_db = self.get_vector_db()
            if not vector_db: raise Exception("No DB loaded")

            if self._is_cancelled(job_id): return

            # 1. Load Model
            target_model = request.model_id if request.model_id else "balanced"
            self.load_llm(target_model)

            if self._is_cancelled(job_id): return

            # 2. Architect Phase
            architect_start = time.time()
            target_pool_size = 100
            topics_pool = self.extract_key_topics(vector_db, target_pool_size, request.language)
            architect_duration = time.time() - architect_start
            
            print(f"\n📋 ARCHITECT POOL ({len(topics_pool)} candidates in {architect_duration:.1f}s):")
            for i, t in enumerate(topics_pool):
                print(f"   {i+1}. {t}")
            print("-" * 30)
            
            # --- START BUILDER PHASE ---
            self.jobs[job_id]["phase"] = "Generating Questions (Builder)..." # AGGIORNAMENTO FASE
            
            # 3. Prepare Batch List
            needed = request.num_questions
            selected_topics_sequence = []
            
            while len(selected_topics_sequence) < needed:
                random.shuffle(topics_pool)
                selected_topics_sequence.extend(topics_pool)
            
            selected_topics_sequence = selected_topics_sequence[:needed]
            
            parser = PydanticOutputParser(pydantic_object=AIQuizOutput)
            all_questions = []
            generated_hashes = []
            generated_concepts_history = []
            
            # 4. Builder Phase
            builder_start = time.time()
            TOPIC_BATCH_SIZE = 10
            topic_batches = [selected_topics_sequence[i:i + TOPIC_BATCH_SIZE] for i in range(0, len(selected_topics_sequence), TOPIC_BATCH_SIZE)]
            
            for batch_idx, batch_topics in enumerate(topic_batches):

                if self._is_cancelled(job_id): return

                if len(all_questions) >= request.num_questions: break
                
                print(f"\n🧱 [BUILDER] Batch {batch_idx + 1}/{len(topic_batches)}")
                
                batch_start_time = time.time()
                
                # Mixed Logic
                type_instructions = []
                for i in range(len(batch_topics)):
                    # Mixed Logic
                    if request.question_type == 'mixed':
                        # Una Open Ended ogni 5, il resto Multiple Choice
                        target_type = "open_ended" if (len(all_questions) + i + 1) % 5 == 0 else "multiple_choice"
                    elif "aperta" in request.question_type or "open" in request.question_type:
                         target_type = "open_ended"
                    else:
                         target_type = "multiple_choice"
                    
                    type_instructions.append(f"- Question {i+1} Type: {target_type}")

                type_constraints_str = "\n".join(type_instructions)

                # Context Retrieval
                multi_context_str = ""
                sources_map = {} 
                
                for idx, t in enumerate(batch_topics):
                    retriever = vector_db.as_retriever(search_kwargs={'k': 3})
                    docs = retriever.invoke(t)
                    t_ctx = "\n".join([d.page_content for d in docs])
                    multi_context_str += f"\n--- TOPIC {idx+1}: {t} ---\nSOURCE MATERIAL:\n{t_ctx}\n"
                    if docs:
                        sources_map[t] = docs[0].metadata.get('source', 'Unknown')

                history_window = generated_concepts_history[-20:]
                history_str = "; ".join(history_window) if history_window else "None"
                
                try:
                    draft_prompt = ChatPromptTemplate.from_template("""
                    Role: Technical Expert.
                    Task: Generate exactly {qty} quiz questions based on the provided context.
                    
                    CONTEXT:
                    {context}
                    
                    REQUIREMENTS:
                    1. Output Format: JSON List.
                    2. Language of Content: {lang} (Questions and Answers must be in {lang}).
                    3. JSON KEYS MUST BE IN ENGLISH: "question", "type", "options", "answer", "explanation".
                    4. "type" values must be strictly: "multiple_choice" or "open_ended".
                    5. For "multiple_choice", generate EXACTLY {max_opts} options.
                    
                    SPECIFIC TYPES:
                    {type_constraints}
                    
                    Output only the raw JSON.
                    """)
                    
                    draft_chain = draft_prompt | self.llm | StrOutputParser()
                    raw_draft = draft_chain.invoke({
                        "qty": len(batch_topics),
                        "context": multi_context_str,
                        "type_constraints": type_constraints_str,
                        "lang": request.language,
                        "max_opts": request.max_options 
                    })
                    
                    refine_prompt = ChatPromptTemplate.from_template("""
                    Role: JSON Editor.
                    Task: Validate and Format JSON.
                    Input Draft: {draft}
                    
                    RULES:
                    1. JSON Keys: "question", "type", "options", "answer", "explanation".
                    2. Content Language: {lang}.
                    3. "type" MUST be "multiple_choice" or "open_ended".
                    4. "answer" must be the exact text of the correct option.
                    
                    Format:
                    {format_instructions}
                    """)

                    if self._is_cancelled(job_id): return
                    
                    refine_chain = refine_prompt | self.llm | StrOutputParser()
                    json_str_output = refine_chain.invoke({
                        "draft": raw_draft,
                        "lang": request.language,
                        "format_instructions": parser.get_format_instructions()
                    })
                    
                    cleaned_json = clean_json_output(json_str_output)
                    try:
                        parsed_data = json.loads(cleaned_json)
                    except json.JSONDecodeError:
                        print("     ❌ JSON Error. Skipping.")
                        continue 
                        
                    if isinstance(parsed_data, list):
                        parsed_data = {"questions": parsed_data}

                    if "questions" in parsed_data and isinstance(parsed_data["questions"], list):
                         for q in parsed_data["questions"]:
                            if "corretta" in q and isinstance(q["corretta"], (int, float)):
                                q["corretta"] = str(q["corretta"])
                            if "opzioni" in q and isinstance(q["opzioni"], list):
                                clean_opts = []
                                for opt in q["opzioni"]:
                                    if isinstance(opt, dict):
                                        val = opt.get('text') or opt.get('value') or list(opt.values())[0]
                                        clean_opts.append(str(val))
                                    else:
                                        clean_opts.append(str(opt))
                                q["opzioni"] = clean_opts
                        
                    structured_output = AIQuizOutput.model_validate(parsed_data)
                    
                    valid_batch_count = 0
                    for i, q in enumerate(structured_output.questions):
                        if q.question in generated_hashes: continue
                        
                        q_dict = {
                            "question": q.question,       
                            "type": q.type,               
                            "options": q.options,         
                            "answer": q.answer,           
                            "explanation": q.explanation, 
                            "source_file": sources_map.get(batch_topics[i] if i < len(batch_topics) else batch_topics[-1], 'Unknown')
                        }
                        
                        all_questions.append(q_dict)
                        generated_hashes.append(q.question)
                        generated_concepts_history.append(q.question[:60])
                        valid_batch_count += 1
                    
                    batch_duration = time.time() - batch_start_time
                    print(f"     ✅ Batch: +{valid_batch_count} Qs ({batch_duration:.1f}s)")
                    
                    self.jobs[job_id]["progress"] = len(all_questions)

                except Exception as e:
                    print(f"     ❌ Batch Error: {e}")
                    continue

            if self._is_cancelled(job_id): return

            builder_duration = time.time() - builder_start
            total_duration = time.time() - job_start_time
            
            print(f"\n{'='*60}")
            print(f"🏁 WORKFLOW COMPLETED")
            print(f"📊 Stats: {len(all_questions)} Qs in {total_duration:.2f}s")
            print(f"{'='*60}\n")

            self.jobs[job_id]["result"] = all_questions[:request.num_questions]
            self.jobs[job_id]["status"] = "completed"
                
        except Exception as e:
            # 8. EXCEPTION HANDLER (Evita di sovrascrivere "cancelled" con "failed")
            if self.jobs[job_id]["status"] != "cancelled":
                print(f"\n❌ [FATAL ERROR] {e}")
                self.jobs[job_id]["status"] = "failed"
                self.jobs[job_id]["error"] = str(e)
            else:
                print(f"\n⛔ Exception ignored because job was cancelled.")

    def get_chat_response(self, question: str, lang: str):
        vector_db = self.get_vector_db()
        if not vector_db: return "Context not found. Please upload a file."
        
        docs = vector_db.as_retriever(search_kwargs={'k': 6}).invoke(question)
        ctx = "\n".join([d.page_content for d in docs])
        
        # PROMPT AGGIORNATO: Usa la variabile {lang}
        prompt = ChatPromptTemplate.from_template("""
        Role: Helpful Assistant.
        Context: {ctx}
        
        User Question: {q}
        
        Task: Answer the question based ONLY on the context provided.
        IMPORTANT: Answer in {lang}.
        """)
        
        chain = prompt | self.llm | StrOutputParser()
        return chain.invoke({"ctx": ctx, "q": question, "lang": lang})

    def grade_answer(self, q, c, u, l):
        print(f"⚖️ Grading Answer... Language: {l}")
        
        # PROMPT AGGIORNATO: "Benevolent Professor"
        prompt = ChatPromptTemplate.from_template("""
        Role: Fair & Expert Examiner.
        Task: Grade the user's answer (0-100) based on the correct answer/context.
        
        INPUT:
        Question: "{q}"
        Reference/Correct Answer: "{c}"
        User Answer: "{u}"
        Output Language: {l}
        
        GRADING RULES:
        1. **IGNORE Typos & Grammar:** Do NOT penalize spelling mistakes (e.g., "algortmo", "perche", missing accents) unless the answer is completely unreadable. Focus ONLY on the meaning.
        2. **Semantic Match:** If the user conveys the core concept correctly, give a HIGH score (90-100), even if the phrasing is informal.
        3. **Technical Accuracy:** If the user mentions correct advanced concepts (like Shannon's Theorem, K >= M, etc.) that are relevant, REWARD them, do not criticize them for being "brief".
        4. **Feedback Tone:** Be encouraging. If the answer is correct but has typos, mention the typos gently in the feedback but DO NOT lower the score for them.
        
        OUTPUT FORMAT (JSON):
        {{
            "score": <int 0-100>,
            "feedback": "<string in {l}>",
            "ideal_answer": "<string in {l}>"
        }}
        """)
        
        chain = prompt | self.llm | StrOutputParser()
        
        try:
            res = chain.invoke({"q": q, "c": c, "u": u, "l": l})
            cleaned_json = clean_json_output(res)
            return json.loads(cleaned_json)
        except Exception as e:
            print(f"   ❌ Grading Error: {e}")
            return {
                "score": 0, 
                "feedback": "Error evaluating answer. Please try again.", 
                "ideal_answer": c
            }
        
    def regenerate_question(self, current_question_text, instruction, lang):
        print(f"♻️ Regenerating: {current_question_text[:30]}... | Instr: {instruction}")
        
        # PROMPT ROBUSTO: Forza schema Inglese e struttura valida
        prompt = ChatPromptTemplate.from_template("""
        Role: Senior Quiz Editor.
        Task: Rewrite the quiz question following the user's instruction.
        
        INPUT DATA:
        Original Question: "{q}"
        User Instruction: "{i}"
        Target Language: {l}
        
        STRICT OUTPUT SCHEMA (JSON):
        {{
            "question": "The rewritten question text",
            "type": "multiple_choice" or "open_ended",
            "options": ["Option 1", "Option 2", "Option 3", "Option 4"],
            "answer": "The correct option text (must match one option exactly)",
            "explanation": "Brief explanation of the answer"
        }}
        
        RULES:
        1. "type" MUST be strictly "multiple_choice" or "open_ended".
        2. If "multiple_choice", provide exactly 4 options.
        3. If "open_ended", "options" should be an empty list [].
        4. Output valid JSON only. NO Markdown code blocks.
        """)
        
        chain = prompt | self.llm | StrOutputParser()
        
        try:
            raw_res = chain.invoke({"q": current_question_text, "i": instruction, "l": lang})
            cleaned_json = clean_json_output(raw_res)
            data = json.loads(cleaned_json)

            validated_q = AIQuestion(**data)

            return {
                "question": validated_q.question,
                "type": validated_q.type,         
                "options": validated_q.options,
                "answer": validated_q.answer,
                "explanation": validated_q.explanation,
                "source_file": "AI-Edited"        
            }
                
        except Exception as e:
            print(f"   ❌ Regen Error: {e}")
            return None

engine = AIEngine()