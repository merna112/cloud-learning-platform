from fastapi import FastAPI
from kafka import KafkaProducer
import uuid
import json

app = FastAPI()
producer = KafkaProducer(
    bootstrap_servers="kafka:9092",
    value_serializer=lambda v: json.dumps(v).encode()
)

@app.post("/api/quiz/generate")
def generate(document_id: str):
    qid = str(uuid.uuid4())
    producer.send("quiz.generated", {"id": qid})
    return {"id": qid}

@app.get("/api/quiz/{id}")
def get_quiz(id: str):
    return {"id": id, "questions": []}

@app.post("/api/quiz/{id}/submit")
def submit(id: str):
    return {"score": 100}

@app.get("/api/quiz/{id}/results")
def results(id: str):
    return {"id": id, "score": 100}

@app.get("/api/quiz/history")
def history():
    return []

@app.delete("/api/quiz/{id}")
def delete(id: str):
    return {"deleted": id}
