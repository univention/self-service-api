import logging

from fastapi import FastAPI
from uvicorn.config import LOGGING_CONFIG

from config import log_configuration_details
from routers import passwordreset


logger = logging.getLogger(__name__)

LOGGING_CONFIG["formatters"]["default"]["fmt"] = \
    "%(asctime)s [%(name)s] %(levelname)s %(message)s"

logging.basicConfig(
    format="%(asctime)s [%(name)s] %(levelname)s %(message)s",
    level=logging.DEBUG
)

log_configuration_details()


app = FastAPI()
app.include_router(passwordreset.router)


@app.get("/")
async def root():
    return {"message": "Hi"}
