from fastapi import APIRouter, HTTPException

router = APIRouter(
    prefix="/univention/command/passwordreset",
    tags=["passwordreset", "univention", "umc"],
)


@router.post("/get_user_attributes_values")
async def get_user_attributes_values():
    return HTTPException(status_code=418, detail="Test status code")


@router.post("/get_user_attributes_descriptions")
async def get_user_attributes_descriptions():
    return HTTPException(status_code=418, detail="Test status code")
