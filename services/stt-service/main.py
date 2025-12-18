from fastapi import FastAPI, UploadFile
import boto3
import uuid
from kafka import KafkaProducer
import json

app = FastAPI()
s3 = boto3.client("s3")
producer = KafkaProducer(
    bootstrap_servers="kafka:9092",
    value_serializer=lambda v: json.dumps(v).encode()
)

BUCKET = "stt-service-storage-dev"

@app.post("/api/stt/transcribe")
def transcribe(file: UploadFile):
    tid = str(uuid.uuid4())
    s3.upload_fileobj(file.file, BUCKET, f"{tid}.audio")
    producer.send("audio.transcription.completed", {"id": tid})
    return {"id": tid, "text": "transcribed text", "confidence": 0.95}

@app.get("/api/stt/transcription/{id}")
def get_transcription(id: str):
    return {"id": id, "text": "transcribed text", "confidence": 0.95}

@app.get("/api/stt/transcriptions")
def list_transcriptions():
    return []
