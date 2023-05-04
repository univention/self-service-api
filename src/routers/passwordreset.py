import logging
import os
from typing import Any
from urllib.parse import urljoin

import aiohttp
from fastapi import APIRouter, Request, Response, Depends
from pydantic import BaseSettings

from opa import get_opa


class Settings(BaseSettings):
    ucs_host: str = os.environ.get("UCS_BASE_URL")
    ucs_selfservice_prefix: str = urljoin(
        ucs_host, "/univention/command/passwordreset/")


settings = Settings()

logger = logging.getLogger(__name__)


router = APIRouter(
    prefix="/univention/command/passwordreset",
    tags=["passwordreset", "univention", "umc"],
)


@router.post("/get_user_attributes_values")
async def get_user_attributes_values(
        request: Request, response: Response, opa_client: Any = Depends(get_opa)):
    payload = await request.json()
    cookies = request.cookies
    headers = {"x-xsrf-protection": request.headers.get("x-xsrf-protection")} \
        if request.headers.get("x-xsrf-protection") else {}

    async with aiohttp.ClientSession(cookies=cookies) as session:
        url = urljoin(settings.ucs_selfservice_prefix,
                      "get_user_attributes_values")
        async with session.post(url, headers=headers, json=payload) as ucs_response:
            body = await ucs_response.json()
            response.status_code = ucs_response.status
            for key, value in ucs_response.cookies.items():
                response.set_cookie(key, value)

            res = await opa_client.check_policy(
                policy="/v1/data/self_service/filters/user_data_attribute_values",
                data=body.get("result", {}))
            body["result"] = res

            return body


@router.post("/get_user_attributes_descriptions")
async def get_user_attributes_descriptions(
        request: Request, response: Response,
        opa_client: Any = Depends(get_opa)) -> Any:
    payload = await request.json()
    cookies = request.cookies
    headers = {"x-xsrf-protection": request.headers.get("x-xsrf-protection")} \
        if request.headers.get("x-xsrf-protection") else {}

    async with aiohttp.ClientSession(cookies=cookies) as session:
        url = urljoin(settings.ucs_selfservice_prefix,
                      "get_user_attributes_descriptions")
        async with session.post(url, headers=headers, json=payload) as ucs_response:
            body = await ucs_response.json()
            response.status_code = ucs_response.status
            for key, value in ucs_response.cookies.items():
                response.set_cookie(key, value)

            res = await opa_client.check_policy(
                policy="/v1/data/self_service/filters/user_data_attribute_descriptions",
                data=body.get("result", {}))
            body["result"] = res

            return body


@router.post("/{command}")
async def command(request: Request, response: Response, command) -> Any:
    payload = await request.json()
    cookies = request.cookies
    headers = {"x-xsrf-protection": request.headers.get("x-xsrf-protection")} \
        if request.headers.get("x-xsrf-protection") else {}

    async with aiohttp.ClientSession(cookies=cookies) as session:
        url = urljoin(settings.ucs_selfservice_prefix,
                      command)
        async with session.post(url, headers=headers, json=payload) as ucs_response:
            body = await ucs_response.json()
            response.status_code = ucs_response.status
            for key, value in ucs_response.cookies.items():
                response.set_cookie(key, value)
            return body
