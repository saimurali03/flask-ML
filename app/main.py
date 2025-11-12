# app/main.py
from flask import Flask, request, jsonify
import os
import pickle
import numpy as np
from utils.preprocess import preprocess_input

MODEL_PATH = os.environ.get("MODEL_PATH", "model.pkl")

app = Flask(__name__)

# Load model
def load_model(path=MODEL_PATH):
    with open(path, "rb") as f:
        return pickle.load(f)

model = None
try:
    model = load_model()
except Exception as e:
    app.logger.warning(f"Could not load model at {MODEL_PATH}: {e}")

@app.route("/", methods=["GET"])
def home():
    return jsonify({"status": "ok", "message": "Flask ML Prediction API running"})

@app.route("/predict", methods=["POST"])
def predict():
    global model
    if model is None:
        return jsonify({"error": "model not loaded"}), 500
    payload = request.get_json(force=True)
    try:
        features = preprocess_input(payload)
        pred = model.predict([features])
        # If sklearn regression: float; if classification: maybe array
        value = pred[0].item() if hasattr(pred[0], "item") else pred[0]
        return jsonify({"prediction": float(value)})
    except Exception as e:
        return jsonify({"error": str(e)}), 400

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=int(os.environ.get("PORT", 5000)))
