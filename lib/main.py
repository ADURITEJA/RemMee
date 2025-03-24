from fastapi import FastAPI
from pydantic import BaseModel
import groq

# Initialize FastAPI app
app = FastAPI()

# Set your Groq API key
groq_client = groq.Groq(api_key="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")

# Define request model
class ChatRequest(BaseModel):
    message: str

# Chat endpoint using Groq AI
@app.post("/chat/")
async def chat(request: ChatRequest):
    response = groq_client.chat.completions.create(
        model="llama-3.3-70b-versatile",  # Groq supports LLaMA-3 models
        messages=[{"role": "system", "content": "You are a medical assistant."},
                  {"role": "user", "content": request.message}]
    )
    return {"response": response.choices[0].message.content}