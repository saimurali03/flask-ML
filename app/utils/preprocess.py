# app/utils/preprocess.py
import numpy as np

def preprocess_input(payload: dict):
    """
    Convert incoming JSON to a feature vector.
    Modify this to match your trained model's features.
    Expects numeric keys: age, bmi, blood_pressure (example).
    """
    return np.array([
        float(payload.get("age", 0)),
        float(payload.get("bmi", 0)),
        float(payload.get("blood_pressure", 0))
    ])
