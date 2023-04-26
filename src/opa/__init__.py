import os

from opa_client.client import OPAClient


# where to reach the OPA
opa_url = os.environ.get("OPA_URL")
assert opa_url is not None


async def get_opa():
    opa_client = OPAClient(opa_url=opa_url, log_queries=True)
    try:
        yield opa_client
    finally:
        opa_client.shutdown()
