from fastapi import FastAPI

app = FastAPI(title="Hello World API", version="1.0.0")


@app.get("/")
async def root():
    """Return a Hello World message."""
    return {"message": "Hello World"}


@app.get("/health")
async def health():
    """Health check endpoint for Kubernetes probes."""
    return {"status": "healthy"}
