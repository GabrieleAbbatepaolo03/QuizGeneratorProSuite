# 🎓 Quiz Generator Pro Suite

![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)
![Platform](https://img.shields.io/badge/platform-Windows-0078D6.svg)
![Tech](https://img.shields.io/badge/AI-Local_LLM-orange.svg)
![License](https://img.shields.io/badge/license-MIT-green.svg)

**Quiz Generator Pro** is an advanced desktop application that leverages local Generative AI to transform PDF documents into interactive quizzes, flashcards, and study sessions.

Designed for **privacy** and **offline capability**, it eliminates the need for expensive API subscriptions or constant internet connections by running the AI engine directly on your hardware.

📥 **[DOWNLOAD LATEST VERSION HERE](https://github.com/GabrieleAbbatepaolo03/QuizGeneratorProSuite/releases/latest)**

---

## 🚀 Key Features

* **RAG (Retrieval Augmented Generation):** The AI generates questions and answers based *exclusively* on your uploaded PDFs, minimizing hallucinations.
* **Privacy First:** Your documents never leave your machine. All processing is local.
* **Hybrid Study Workflow:**
    * 🖥️ **Workstation:** Use your powerful PC to generate complex quizzes.
    * 💾 **Export JSON:** Save generated sessions in a lightweight format.
    * 💻 **Laptop:** Import quizzes on a low-spec laptop for studying on the go (no AI required for playback).
* **Flexible Quiz Modes:** Supports Multiple Choice, Open-Ended questions, and mixed modes.
* **AI Chat Assistant:** Integrated chat interface to ask specific questions about your documents.

---

## 🛠️ Technical Architecture

This is a Full-Stack application distributed as a single standalone executable:

### 1. Frontend (UI)
* **Framework:** Flutter (Dart).
* **Features:** Native Windows performance, reactive state management, modern adaptive UI.

### 2. Backend (AI Engine)
* **Framework:** Python 3.11 + FastAPI.
* **Packaging:** Compiled via PyInstaller (Zero-dependency for the end user).

### 🧠 AI Stack & Models
We utilize a state-of-the-art local stack optimized for consumer hardware:

* **LLM (Large Language Model):** Powered by **Llama 3.1** (via Ollama) for reasoning and text generation.
* **Embeddings:** `all-MiniLM-L6-v2` (via HuggingFace) for fast and efficient text vectorization.
* **Vector Database:** **FAISS (CPU)**. We selected FAISS for its superior speed and stability on Windows environments compared to heavier alternatives like ChromaDB.
* **Orchestration:** LangChain for managing RAG chains and prompt templates.

---

## 💻 System Requirements

Since AI inference runs locally, performance depends on your hardware. We support two usage modes:

### 1. Study Mode (Laptop / Low-Spec)
*Ideal for taking quizzes and reviewing content (Export/Import JSON).*
* **OS:** Windows 10/11 (64-bit).
* **RAM:** 4 GB.
* **CPU:** Any modern dual-core processor.
* **GPU:** Not required.

### 2. Generator Mode (Workstation / High-Spec)
*Required for generating new quizzes from PDFs using AI.*
* **OS:** Windows 10/11 (64-bit).
* **RAM:** 16 GB recommended (8 GB minimum with swap).
* **CPU:** Recent processor (Intel i5/i7 10th gen+ or AMD Ryzen 5000+).
* **GPU (Recommended):** NVIDIA RTX series (CUDA support) to accelerate Ollama inference.
* **Storage:** ~5 GB (Application + Model weights).

---

## 🔧 Installation

1.  Go to the **[Releases](https://github.com/GabrieleAbbatepaolo03/QuizGeneratorProSuite/releases/latest)** page.
2.  Download the `QuizGeneratorSetup_v1.exe` file.
3.  Run the installer. The application installs into your local user folder (`AppData`) to ensure full write permissions without requiring Admin rights.
4.  Launch **Quiz Generator Pro** from your Desktop shortcut.

---

## 👨‍💻 Build from Source

If you want to contribute or build the project yourself:

### Prerequisites
* Flutter SDK
* Python 3.11
* C++ Build Tools (for Python dependencies)
* Inno Setup (for packaging)

### Backend Setup
```bash
cd backend
python -m venv venv
.\venv\Scripts\activate
pip install -r requirements.txt
# Build Executable
pyinstaller --name quiz_backend --onedir --add-data "src;src" --collect-all langchain --collect-all faiss_cpu entry_point.py
