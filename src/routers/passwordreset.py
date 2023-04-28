import logging
from urllib.parse import urljoin
from typing import Any

import aiohttp
from fastapi import APIRouter, Request, Response, Depends

from config import settings
from opa import get_opa


logger = logging.getLogger(__name__)


router = APIRouter(
    prefix="/univention/command/passwordreset",
    tags=["passwordreset", "univention", "umc"],
)


auth = aiohttp.BasicAuth(
    "portal-server", settings.ucs_internal_auth_secret.get_secret_value())


@router.post("/get_user_attributes_values")
async def get_user_attributes_values(
        request: Request, response: Response, opa_client: Any = Depends(get_opa)):
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

    logger.debug("Request to get_user_attributes_values")

    async with aiohttp.ClientSession(cookies=cookies, auth=auth) as session:
        url = urljoin(settings.ucs_selfservice_base_url,
                      "get_user_attributes_values")
        logger.debug("Forwarding to %s", url)

        async with session.post(url, headers=headers, json=payload) as ucs_response:
            body = await ucs_response.json()
            logger.debug("Got response from selfservice: %s", body)
            response.status_code = ucs_response.status
            for key, value in ucs_response.cookies.items():
                response.set_cookie(key, value)

            logger.debug("Calling to OPA")
            res = await opa_client.check_policy(
                policy="/v1/data/self_service/filters/user_data_attribute_values",
                data=body.get("result", {}))
            body["result"] = res

            logger.debug("Returning %s", body)
            return body


@router.post("/get_user_attributes_descriptions")
async def get_user_attributes_descriptions(
        request: Request, response: Response,
        opa_client: Any = Depends(get_opa)) -> Any:
    payload = await request.json()
    cookies = request.cookies
    headers = {key: request.headers[key]
               for key in ['accept-language', 'x-requested-with', 'x-xsrf-protection']}
    token = request.headers.get('authorization').split('Bearer ')[-1]
    if token:
        logger.info('Got token: %s', token)

    logger.debug("Request to get_user_attributes_descriptions")

    async with aiohttp.ClientSession(cookies=cookies, auth=auth) as session:
        url = urljoin(settings.ucs_selfservice_base_url,
                      "get_user_attributes_descriptions")
        logger.debug("Forwarding to %s", url)

        async with session.post(url, headers=headers, json=payload) as ucs_response:
            body = await ucs_response.json()
            logger.debug("Got response from selfservice: %s", body)
            response.status_code = ucs_response.status
            for key, value in ucs_response.cookies.items():
                response.set_cookie(key, value)

            logger.debug("Calling to OPA")
            res = await opa_client.check_policy(
                policy="/v1/data/self_service/filters/user_data_attribute_descriptions",
                data=body.get("result", {}))
            logger.debug("Got OPA result")
            body["result"] = res

            logger.debug("Returning %s", body)
            return body


@router.post("/{command}")
async def command(request: Request, response: Response, command) -> Any:
    payload = await request.json()
    cookies = request.cookies
    headers = {"x-xsrf-protection": request.headers.get("x-xsrf-protection")} \
        if request.headers.get("x-xsrf-protection") else {}

    logger.debug("Request to %s", command)

    async with aiohttp.ClientSession(cookies=cookies, auth=auth) as session:
        url = urljoin(settings.ucs_selfservice_base_url,
                      command)
        logger.debug("Forwarding request to %s", url)

        async with session.post(url, headers=headers, json=payload) as ucs_response:
            body = await ucs_response.json()
            logger.debug("Got response")
            response.status_code = ucs_response.status
            for key, value in ucs_response.cookies.items():
                response.set_cookie(key, value)
            return body
