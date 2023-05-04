
# Helm charts for the OPA PoC


## Usage

Copy the `*.example` files and adjust them for the current environment.

Install the charts with
`helm install <parameters> self-service-api ./self-service-api`

Add custom values with the
`--values values-self-service-api.yaml`
parameter.
See
`values-self-service-api.yaml.example`
for important values.

Other changeable parameters can be found in the `values.yaml`
files of the respective project-directories.


## Documenting the Helm charts


The documentation of the helm charts is generated mainly out of two places:

- `values.yaml` contains the documentation of the supported configuration
  options.

- `README.md.gotmpl` is the template to generate the `README.md` file, it does
  contain additional prose documentation.

As a generator the tool `helm-docs` is in use. We support two main local usage scenarios:

- `helm-docs` runs it locally. Needs a local installation first.

- `docker compose run helm-docs` allows to use a pre-defined docker container in
  which `helm-docs` is available. Can be used in the folder `/docker` in this
  repository.
