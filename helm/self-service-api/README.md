# self-service-api

![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 0.0.1](https://img.shields.io/badge/AppVersion-0.0.1-informational?style=flat-square)

Proof-of-Concept for the integration of the portal self-service API with OPA

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` |  |
| autoscaling.enabled | bool | `false` |  |
| autoscaling.maxReplicas | int | `100` |  |
| autoscaling.minReplicas | int | `1` |  |
| autoscaling.targetCPUUtilizationPercentage | int | `80` |  |
| fullnameOverride | string | `""` |  |
| image.imagePullPolicy | string | `"Always"` |  |
| image.registry | string | `"registry.souvap-univention.de"` |  |
| image.repository | string | `"souvap/tooling/images/self-service-api/self-service-api"` |  |
| image.tag | string | `"latest"` |  |
| imagePullSecrets | list | `[]` |  |
| ingress.annotations | object | `{}` |  |
| ingress.className | string | `"nginx"` |  |
| ingress.enabled | bool | `false` |  |
| ingress.host | string | `"portal.example"` |  |
| ingress.paths[0].path | string | `"/univention/command/passwordreset/(.*)"` |  |
| ingress.paths[0].pathType | string | `"Prefix"` |  |
| ingress.tls.enabled | bool | `true` |  |
| ingress.tls.secretName | string | `""` |  |
| nameOverride | string | `""` |  |
| nodeSelector | object | `{}` |  |
| podAnnotations | object | `{}` |  |
| podSecurityContext | object | `{}` |  |
| replicaCount | int | `1` |  |
| resources | object | `{}` |  |
| securityContext | object | `{}` |  |
| self_service_api.environment | string | `"staging"` |  |
| self_service_api.opa_url | string | `"http://self-service-opa"` |  |
| self_service_api.ucs_base_url | string | `"http://univention-corporate-server"` |  |
| service.port | int | `80` |  |
| service.type | string | `"ClusterIP"` |  |
| serviceAccount.annotations | object | `{}` |  |
| serviceAccount.create | bool | `true` |  |
| serviceAccount.name | string | `""` |  |
| tolerations | list | `[]` |  |

