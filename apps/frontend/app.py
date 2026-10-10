import os
import httpx
import redis
import uvicorn
from fastapi import FastAPI, Form, HTTPException
from fastapi.responses import HTMLResponse, Response
from prometheus_client import Counter, Histogram, generate_latest, CONTENT_TYPE_LATEST

app = FastAPI(title="Frontend Gate")

# Redis init
REDIS_HOST = os.getenv("REDIS_HOST", "localhost")
REDIS_PORT = int(os.getenv("REDIS_PORT", 6379))
REDIS_PASSWORD = os.getenv("REDIS_PASSWORD", "")

r = redis.Redis(host=REDIS_HOST, port=REDIS_PORT, password=REDIS_PASSWORD, decode_responses=True)

# Backend URL
ANALYTICS_SERVICE_URL = os.getenv("ANALYTICS_SERVICE_URL", "http://localhost:8001")

# --PROMETHEUS METRICS--
# Custom metrics!
REQUEST_COUNT = Counter(
    "http_requests_total",
    "Total number of HTTP requests processed",
    ["method", "endpoint", "http_status"]
)
ANALYTICS_DURATION = Histogram(
    "analytics_processing_seconds",
    "Time spent processing text analytics request via backend"
)

@app.get("/metrics")
def metrics():
    #Prometheus scrape endpoint
    return Response(content=generate_latest(), media_type=CONTENT_TYPE_LATEST)

@app.get("/healthz")
def health_check():
    return {"status": "healthy"}

@app.get("/", response_class=HTMLResponse)
async def index():
    REQUEST_COUNT.labels(method="GET", endpoint="/", http_status="200").inc()

    # Pull tail 5 requests from Redis
    try:
        recent_history = r.lrange("history", 0, 4)
    except redis.exceptions.ConnectionError:
        recent_history = ["Redis unavailable"]

    history_html = "".join([f"<li>{item}</li>" for item in recent_history])

    # HTML Interface
    html_content = f"""
    <html>
        <head><title>Mood Detector</title></head>
        <body style="font-family: Arial, sans-serif; margin: 40px;">
            <h2>Devops Demo: Mood Detector</h2>
            <form action="/submit" method="post">
                <input type="text" name="user_text" placeholder="Write something..." style="width:300px; padding:8px;" required>
                <input type="submit" value="Analyze" style="padding:8px;">
            </form>
            <h3>Recent Analysis History (from Redis):</h3>
            <ul>{history_html}</ul>
        </body>
    </html>
    """
    return html_content

@app.post("/submit")
async def submit_text(user_text: str = Form(...)):
    try:
        # Send request to backend and count time
        with ANALYTICS_DURATION.time():
            async with httpx.AsyncClient() as client:
                response = await client.post(
                    f"{ANALYTICS_SERVICE_URL}/analyze",
                    json={"text": user_text},
                    timeout=5.0
                )

        if response.status_code != 200:
            REQUEST_COUNT.labels(method="POST", endpoint="/submit", http_status=str(response.status_code)).inc()
            raise HTTPException(status_code=500, detail="Backend error")

        data = response.json()
        result_str = f"Text: '{user_text}' -> Length: {data['text_length']} | Sentiment: {data['sentiment']}"

        # Write result to Redis
        try:
            r.lpush("history", result_str)
            r.ltrim("history", 0, 19)       # Store only tail 20 registries
        except redis.exceptions.ConnectionError:
            pass                            # If Redis is down, app still gives a response

        REQUEST_COUNT.labels(method="POST", endpoint="/submit", http_status="200").inc()

        # Give user a response
        return HTMLResponse(content=f"""
            <body style="font-family: Arial, sans-serif; margin: 40px;">
                <h3>Analysis Result:</h3>
                <p><b>{result_str}</b></p>
                <a href="/">Go Back</a>
            </body>
        """)

    except Exception as e:
        REQUEST_COUNT.labels(method="POST", endpoint="/submit", http_status="500").inc()
        return HTMLResponse(content=f"<h3>Error: {str(e)}</h3><br><a href='/'>Go Back</a>", status_code=500)

if __name__ == "__main__":
    port = int(os.getenv("PORT", 8000))
    uvicorn.run(app, host="0.0.0.0", port=port)