from fastapi import FastAPI

from routers import passwordreset


app = FastAPI()

app.include_router(passwordreset.router)

@app.get("/")
async def root():
    return {"message": "Hi"}
