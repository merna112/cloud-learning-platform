from fastapi import FastAPI
from gtts import gTTS
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

BUCKET = "tts-service-storage-dev"

@app.post("/api/tts/synthesize")
def synthesize(text: str, lang: str = "en"):
    audio_id = str(uuid.uuid4())
    file_path = f"/tmp/{audio_id}.mp3"
    gTTS(text=text, lang=lang).save(file_path)
    s3.upload_file(file_path, BUCKET, f"{audio_id}.mp3")
    producer.send("audio.generation.completed", {"id": audio_id})
    return {"id": audio_id}

@app.get("/api/tts/audio/{id}")
def get_audio(id: str):
    return {"url": f"s3://{BUCKET}/{id}.mp3"}

@app.delete("/api/tts/audio/{id}")
def delete_audio(id: str):
    s3.delete_object(Bucket=BUCKET, Key=f"{id}.mp3")
    return {"deleted": id}
