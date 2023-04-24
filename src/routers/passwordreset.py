import logging
import os
from typing import Any
from urllib.parse import urljoin

import aiohttp
from fastapi import APIRouter, Request, Response


# where to reach the UCS host
ucs_host = os.environ["UCS_BASE_URL"]
# where to reach the self-service module
ucs_selfservice_prefix = urljoin(
    ucs_host, "/univention/command/passwordreset/")

logger = logging.getLogger(__name__)

router = APIRouter(
    prefix="/univention/command/passwordreset",
    tags=["passwordreset", "univention", "umc"],
)


@router.post("/get_user_attributes_values")
async def get_user_attributes_values(request: Request, response: Response):
    payload = await request.json()
    cookies = request.cookies
    headers = {"x-xsrf-protection": request.headers["x-xsrf-protection"]}

    async with aiohttp.ClientSession(cookies=cookies) as session:
        url = urljoin(ucs_selfservice_prefix,
                      "get_user_attributes_descriptions")
        async with session.post(url, headers=headers, json=payload) as ucs_response:
            body = await ucs_response.json()
            response.status_code = ucs_response.status
            for key, value in ucs_response.cookies.items():
                response.set_cookie(key, value)
            return body


@router.post("/get_user_attributes_descriptions")
async def get_user_attributes_descriptions(request: Request, response: Response) -> Any:
    payload = await request.json()
    cookies = request.cookies
    headers = {"x-xsrf-protection": request.headers["x-xsrf-protection"]}

    async with aiohttp.ClientSession(cookies=cookies) as session:
        url = urljoin(ucs_selfservice_prefix,
                      "get_user_attributes_descriptions")
        async with session.post(url, headers=headers, json=payload) as ucs_response:
            body = await ucs_response.json()
            response.status_code = ucs_response.status
            for key, value in ucs_response.cookies.items():
                response.set_cookie(key, value)

            for attribute in body.get("result", {}):
                # TODO: let OPA make the decision...
                attribute["editable"] = False
                attribute["readonly"] = True

            return body
