import re
import platform
import psutil
import shutil

def clean_json_output(text: str) -> str:
    # Rimuove i blocchi markdown
    text = re.sub(r"```json\s*", "", text)
    text = re.sub(r"```\s*", "", text)
    text = text.strip()
    
    # Cerca graffe json
    start = text.find('{')
    end = text.rfind('}') + 1
    
    if start != -1 and end != -1:
        return text[start:end]
    
    return text

def get_hardware_specs():
    specs = {
        "cpu": platform.processor() or platform.machine(),
        "ram_total": "N/A",
        "ram_used": "N/A",
        "gpu": "CPU Mode"
    }

    try:
        mem = psutil.virtual_memory()
        specs["ram_total"] = f"{round(mem.total / (1024**3), 1)} GB"
        specs["ram_used"] = f"{mem.percent}%"
    except Exception:
        pass

    return specs