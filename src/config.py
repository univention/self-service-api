import logging

from pydantic import BaseSettings, Field, SecretStr


logger = logging.getLogger(__name__)


class Settings(BaseSettings):
    opa_url: str = Field(...)
    ucs_internal_auth_secret: SecretStr = "univention"
    ucs_selfservice_base_url: str = Field(...)

settings = Settings()


def log_configuration_details():
    logger.info("Configuration: %s", settings.dict())
