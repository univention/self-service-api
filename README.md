# self-service API with OPA

This repository contains a Proof-of-Concept for the integration of the portal
self-service API with [OPA](https://www.openpolicyagent.org/).

## Architecture

As a first approach, the following architecture has been sketched:

[!architecture]("docs/concept/images/architecture.png")

The idea behind it is to implement OPA in a self-contained way, that does not
affect the front-end (given a configured reverse proxy). As a result, there
should exist a drop-in replacement for the self-service API.
