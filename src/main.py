import logging

from fastapi import FastAPI
from uvicorn.config import LOGGING_CONFIG

from routers import passwordreset


LOGGING_CONFIG["formatters"]["default"]["fmt"] = \
    "%(asctime)s [%(name)s] %(levelname)s %(message)s"

logging.basicConfig(
    format="%(asctime)s [%(name)s] %(levelname)s %(message)s",
    level=logging.DEBUG
)

app = FastAPI()
app.include_router(passwordreset.router)


@app.get("/")
async def root():
    return {"message": "Hi"}
