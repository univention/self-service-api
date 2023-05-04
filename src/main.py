import logging

from fastapi import FastAPI
from uvicorn.config import LOGGING_CONFIG

from routers import passwordreset


logger = logging.getLogger(__name__)

LOGGING_CONFIG["formatters"]["default"]["fmt"] = \
    "%(asctime)s [%(name)s] %(levelname)s %(message)s"

logging.basicConfig(
    format="%(asctime)s [%(name)s] %(levelname)s %(message)s",
    level=logging.DEBUG
)


logger.info("Using ucs_host %s", passwordreset.settings.ucs_host)
logger.info(
    "Using ucs_selfservice_prefix %s", passwordreset.settings.ucs_selfservice_prefix)


app = FastAPI()
app.include_router(passwordreset.router)


@app.get("/")
async def root():
    return {"message": "Hi"}
