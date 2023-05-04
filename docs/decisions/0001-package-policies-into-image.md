# Package OPA policies into container image

---

- status: accepted
- date: 2023-05-03
- deciders: jconda, tkintscher, jbornhold

---

## Context

For the PoC of the OPA integration we need a way to provide example policies
which can be used in the PoC deployment.

The policies have to be available for the running OPA process at runtime.

## Decision

For now we are adding the policy files into the OPA image.

## Consequences

The PoC implementation will stay simple.

A production grade solution will have to contain a solution for providing the
policy files at runtime, so that a given container image (ideally the unchanged
upstream image) can be used together with the custom set of policies.
