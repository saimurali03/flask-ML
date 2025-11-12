# app/Dockerfile
FROM python:3.10-slim

ENV PYTHONUNBUFFERED=1
WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

# set a non-root user (optional)
RUN useradd -m appuser || true
USER appuser

EXPOSE 5000
CMD ["gunicorn", "main:app", "-b", "0.0.0.0:5000", "--workers=2", "--threads=4"]
