from opa_client.client import OPAClient

from config import settings


async def get_opa():
    opa_client = OPAClient(opa_url=settings.opa_url, log_queries=True)
    try:
        yield opa_client
    finally:
        await opa_client.shutdown()
