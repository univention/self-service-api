# self-service API with OPA

This repository contains a Proof-of-Concept for the integration of the portal
self-service API with [OPA](https://www.openpolicyagent.org/).

## Local development

This repository uses and is strongly based on all the containers resulting
from [`univention-portal`](https://git.knut.univention.de/univention/components/univention-portal).

To get started, follow this steps:
1. Configure your `.env` file based upon `.env.example`.
    1. If you are using Mac, please change the local IPs to `host.docker.internal`.
2. Use `docker compose up -d --build` to bring the setup up.

# pre-commit

This repository makes use of [`pre-commit`](https://pre-commit.com/), please ensure you install them.
They are also checked on the pipeline.

## Architecture

As a first approach, the following architecture has been sketched:

![architecture](docs/concept/images/architecture.png)

The idea behind it is to implement OPA in a self-contained way, that does not
affect the front-end (given a configured reverse proxy). As a result, there
should exist a drop-in replacement for the self-service API.
