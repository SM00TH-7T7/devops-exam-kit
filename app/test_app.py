from app import app

def test_health():
    response = app.test_client().get("/health")
    assert response.status_code == 200
    assert response.json == {"status": "ok"}

def test_config(monkeypatch):
    monkeypatch.setenv("APP_MESSAGE", "Exam configuration")
    monkeypatch.setenv("API_TOKEN", "test-only")
    response = app.test_client().get("/")
    assert response.json == {"message": "Exam configuration", "secret_configured": True}
    assert "test-only" not in response.text

def test_metrics():
    client = app.test_client()
    client.get("/")
    response = client.get("/metrics")
    assert response.status_code == 200
    assert b"exam_requests_total" in response.data
