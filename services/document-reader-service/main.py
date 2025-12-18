from fastapi import FastAPI, UploadFile
from kafka import KafkaProducer
import uuid
import json

app = FastAPI()
producer = KafkaProducer(
    bootstrap_servers="kafka:9092",
    value_serializer=lambda v: json.dumps(v).encode()
)

@app.post("/api/documents/upload")
def upload(file: UploadFile):
    did = str(uuid.uuid4())
    producer.send("document.uploaded", {"id": did})
    producer.send("document.processed", {"id": did})
    producer.send("notes.generated", {"id": did})
    return {"id": did}

@app.get("/api/documents/{id}")
def get_doc(id: str):
    return {"id": id}

@app.get("/api/documents/{id}/notes")
def get_notes(id: str):
    return {"id": id, "notes": "generated notes"}

@app.post("/api/documents/{id}/regenerate-notes")
def regen(id: str):
    return {"id": id}

@app.get("/api/documents")
def list_docs():
    return []

@app.delete("/api/documents/{id}")
def delete_doc(id: str):
    return {"deleted": id}
