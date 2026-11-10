import os
from flask import Flask, jsonify, Response
from prometheus_client import Counter, generate_latest, CONTENT_TYPE_LATEST

app = Flask(__name__)
requests_total = Counter("exam_requests_total", "Requests to the greeting endpoint")

@app.get("/")
def index():
    requests_total.inc()
    return jsonify(message=os.getenv("APP_MESSAGE", "Hello DevOps!"),
                   secret_configured=bool(os.getenv("API_TOKEN")))

@app.get("/health")
def health():
    return jsonify(status="ok")

@app.get("/metrics")
def metrics():
    return Response(generate_latest(), content_type=CONTENT_TYPE_LATEST)

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
