import logging

from fastapi import FastAPI
import uvicorn.config

from routers import passwordreset


logging.basicConfig(
    format="%(levelprefix)s %(message)s",
    level=logging.DEBUG
)

app = FastAPI()
app.include_router(passwordreset.router)


@app.get("/")
async def root():
    return {"message": "Hi"}
