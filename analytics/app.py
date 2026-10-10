import os
import uvicorn
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel

app = FastAPI(title="Analytics Service Backend")

class TextPayload(BaseModel):
    text: str

class AnalyticsResponse(BaseModel):
    text_length: int
    sentiment: str

@app.get("/healthz")
def health_check():
    #K8s liveness/readiness probes endpoint
    return {"status": "healthy"}

@app.post("/analyze", response_model=AnalyticsResponse)
async def analyze_text(payload: TextPayload):
    if not payload.text.strip():
        raise HTTPException(status_code=400, detail="Text cannot be empty")

    #Logic!
    length = len(payload.text)
    if length > 15:
        sentiment = "Positive / Detailed"
    elif length > 5:
        sentiment = "Neutral / Short"
    else:
        sentiment = "Negative / Too brief"

    return {
        "text_length": length,
        "sentiment": sentiment
    }

if __name__ == "__main__":
    port = int(os.getenv("PORT", 8001))
    uvicorn.run(app, host="0.0.0.0", port=port)