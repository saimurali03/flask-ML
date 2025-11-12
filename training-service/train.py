import os
import pickle
import numpy as np
from sklearn.linear_model import LinearRegression

# Create sample training data
X = np.random.rand(200, 3)
y = X[:, 0] * 3.5 + X[:, 1] * 2.2 + 0.1 * np.random.randn(200)

model = LinearRegression()
model.fit(X, y)

out_dir = os.environ.get("OUT_DIR", "/data")
os.makedirs(out_dir, exist_ok=True)
model_path = os.path.join(out_dir, "model.pkl")

with open(model_path, "wb") as f:
    pickle.dump(model, f)

print(f"✅ Model trained and saved to {model_path}")
