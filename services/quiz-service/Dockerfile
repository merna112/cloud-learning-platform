FROM python:3.11-slim AS builder
WORKDIR /app
RUN pip install --no-cache-dir fastapi uvicorn boto3 kafka-python gtts
FROM python:3.11-slim
WORKDIR /app
COPY --from=builder /usr/local /usr/local
COPY app.py .
EXPOSE 8000
HEALTHCHECK CMD curl -f http://localhost:8000/health || exit 1
CMD ["uvicorn","app:app","--host","0.0.0.0","--port","8000"]
