import logging
import os
from typing import Any
from urllib.parse import urljoin

import aiohttp
from fastapi import APIRouter, Request, Response
from opa_client.client import OPAClient


# where to reach the UCS host
ucs_host = os.environ.get("UCS_BASE_URL")
assert ucs_host is not None
opa_url = os.environ.get("OPA_URL")
assert opa_url is not None
# where to reach the self-service module
ucs_selfservice_prefix = urljoin(
    ucs_host, "/univention/command/passwordreset/")

logger = logging.getLogger(__name__)

opa_client = OPAClient(opa_url=opa_url, log_queries=True)

router = APIRouter(
    prefix="/univention/command/passwordreset",
    tags=["passwordreset", "univention", "umc"],
)


@router.post("/get_user_attributes_values")
async def get_user_attributes_values(request: Request, response: Response):
    payload = await request.json()
    cookies = request.cookies
    headers = {key: request.headers[key]
               for key in ['accept-language', 'x-requested-with', 'x-xsrf-protection']}

    token = request.headers.get('authorization').split('Bearer ')[-1]
    if token:
        valid = await opa_client.check_policy_true(
            policy="/v1/data/auth/token/token_valid",
            data={"token": token, "aud": "notifications-api"}
        )
        claims = await opa_client.check_policy(
            policy="/v1/data/auth/token/decode_valid_token",
            data={"token": token, "aud": "notifications-api"}
        )
        logger.info('Got %s token', 'valid' if valid else 'invalid')
        logger.info('Token claims: %s', claims)

    async with aiohttp.ClientSession(cookies=cookies) as session:
        url = urljoin(ucs_selfservice_prefix,
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
async def get_user_attributes_descriptions(request: Request, response: Response) -> Any:
    payload = await request.json()
    cookies = request.cookies
    headers = {key: request.headers[key]
               for key in ['accept-language', 'x-requested-with', 'x-xsrf-protection']}
    token = request.headers.get('authorization').split('Bearer ')[-1]
    if token:
        logger.info('Got token: %s', token)

    async with aiohttp.ClientSession(cookies=cookies) as session:
        url = urljoin(ucs_selfservice_prefix,
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
async def get_user_attributes_descriptions(request: Request, response: Response, command) -> Any:
    payload = await request.json()
    cookies = request.cookies
    headers = {"x-xsrf-protection": request.headers.get("x-xsrf-protection")} if request.headers.get(
        "x-xsrf-protection") else {}

    async with aiohttp.ClientSession(cookies=cookies) as session:
        url = urljoin(ucs_selfservice_prefix,
                      command)
        async with session.post(url, headers=headers, json=payload) as ucs_response:
            body = await ucs_response.json()
            response.status_code = ucs_response.status
            for key, value in ucs_response.cookies.items():
                response.set_cookie(key, value)
            return body
