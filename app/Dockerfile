# ---------- build stage ----------
FROM python:3.12-slim AS builder

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir --target=/app/deps -r requirements.txt

# ---------- runtime stage ----------
FROM python:3.12-slim

WORKDIR /app

# Copy installed dependencies from builder
COPY --from=builder /app/deps /app/deps
ENV PYTHONPATH=/app/deps

COPY main.py .

EXPOSE 8000

# Run with uvicorn
CMD ["python", "-m", "uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
