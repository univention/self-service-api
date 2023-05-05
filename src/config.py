import logging
import os
from urllib.parse import urljoin

from pydantic import BaseSettings, SecretStr


logger = logging.getLogger(__name__)


class Settings(BaseSettings):
    opa_url: str = ...
    ucs_internal_auth_secret: SecretStr = "univention"
    ucs_host: str = os.environ.get("UCS_BASE_URL")
    ucs_selfservice_prefix: str = urljoin(
        ucs_host, "/univention/command/passwordreset/")


settings = Settings()


def log_configuration_details():
    logger.info("Configuration: %s", settings.dict())
