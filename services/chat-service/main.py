from fastapi import FastAPI
from kafka import KafkaProducer
import uuid
import json

app = FastAPI()
producer = KafkaProducer(
    bootstrap_servers="kafka:9092",
    value_serializer=lambda v: json.dumps(v).encode()
)

@app.post("/api/chat/message")
def chat(message: str):
    cid = str(uuid.uuid4())
    producer.send("chat.message", {"id": cid, "message": message})
    return {"id": cid, "response": "AI response"}

@app.get("/api/chat/conversations")
def list_conversations():
    return []

@app.get("/api/chat/conversations/{id}")
def get_conversation(id: str):
    return {"id": id, "messages": []}

@app.delete("/api/chat/conversations/{id}")
def delete_conversation(id: str):
    return {"deleted": id}
