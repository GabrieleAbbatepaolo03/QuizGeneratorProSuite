import uvicorn
import os
import sys

# src path
sys.path.append(os.path.join(os.path.dirname(__file__), "src"))

from src.main import app

if __name__ == "__main__":
    uvicorn.run(app, host="127.0.0.1", port=8001)