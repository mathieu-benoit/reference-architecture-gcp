# htc_res_defs
<!-- BEGIN_TF_DOCS -->


### Providers

| Name | Version |
|------|---------|
| humanitec | n/a |

### Resources

| Name | Type |
|------|------|
| [humanitec_agent.agent](https://registry.terraform.io/providers/humanitec/humanitec/latest/docs/resources/agent) | resource |
| [humanitec_key.operator](https://registry.terraform.io/providers/humanitec/humanitec/latest/docs/resources/key) | resource |
| [humanitec_resource_account.cluster_account](https://registry.terraform.io/providers/humanitec/humanitec/latest/docs/resources/resource_account) | resource |
| [humanitec_resource_account.terraform_provisioner_account](https://registry.terraform.io/providers/humanitec/humanitec/latest/docs/resources/resource_account) | resource |
| [humanitec_resource_definition.agent](https://registry.terraform.io/providers/humanitec/humanitec/latest/docs/resources/resource_definition) | resource |
| [humanitec_resource_definition.app_config](https://registry.terraform.io/providers/humanitec/humanitec/latest/docs/resources/resource_definition) | resource |
| [humanitec_resource_definition.base_env](https://registry.terraform.io/providers/humanitec/humanitec/latest/docs/resources/resource_definition) | resource |
| [humanitec_resource_definition.gcp_vertex_ai_default](https://registry.terraform.io/providers/humanitec/humanitec/latest/docs/resources/resource_definition) | resource |
| [humanitec_resource_definition.gcs_default](https://registry.terraform.io/providers/humanitec/humanitec/latest/docs/resources/resource_definition) | resource |
| [humanitec_resource_definition.gcs_iam_member_default](https://registry.terraform.io/providers/humanitec/humanitec/latest/docs/resources/resource_definition) | resource |
| [humanitec_resource_definition.gke_config](https://registry.terraform.io/providers/humanitec/humanitec/latest/docs/resources/resource_definition) | resource |
| [humanitec_resource_definition.hpa](https://registry.terraform.io/providers/humanitec/humanitec/latest/docs/resources/resource_definition) | resource |
| [humanitec_resource_definition.ingress](https://registry.terraform.io/providers/humanitec/humanitec/latest/docs/resources/resource_definition) | resource |
| [humanitec_resource_definition.k8s_cluster](https://registry.terraform.io/providers/humanitec/humanitec/latest/docs/resources/resource_definition) | resource |
| [humanitec_resource_definition.k8s_namespace](https://registry.terraform.io/providers/humanitec/humanitec/latest/docs/resources/resource_definition) | resource |
| [humanitec_resource_definition.k8s_service_account](https://registry.terraform.io/providers/humanitec/humanitec/latest/docs/resources/resource_definition) | resource |
| [humanitec_resource_definition.redis_in_cluster](https://registry.terraform.io/providers/humanitec/humanitec/latest/docs/resources/resource_definition) | resource |
| [humanitec_resource_definition.vertex_ai_iam_member_default](https://registry.terraform.io/providers/humanitec/humanitec/latest/docs/resources/resource_definition) | resource |
| [humanitec_resource_definition.workload](https://registry.terraform.io/providers/humanitec/humanitec/latest/docs/resources/resource_definition) | resource |
| [humanitec_resource_definition_criteria.agent](https://registry.terraform.io/providers/humanitec/humanitec/latest/docs/resources/resource_definition_criteria) | resource |
| [humanitec_resource_definition_criteria.app_config](https://registry.terraform.io/providers/humanitec/humanitec/latest/docs/resources/resource_definition_criteria) | resource |
| [humanitec_resource_definition_criteria.base_env](https://registry.terraform.io/providers/humanitec/humanitec/latest/docs/resources/resource_definition_criteria) | resource |
| [humanitec_resource_definition_criteria.gcp_vertex_ai_default](https://registry.terraform.io/providers/humanitec/humanitec/latest/docs/resources/resource_definition_criteria) | resource |
| [humanitec_resource_definition_criteria.gcs_default](https://registry.terraform.io/providers/humanitec/humanitec/latest/docs/resources/resource_definition_criteria) | resource |
| [humanitec_resource_definition_criteria.gcs_iam_member_default](https://registry.terraform.io/providers/humanitec/humanitec/latest/docs/resources/resource_definition_criteria) | resource |
| [humanitec_resource_definition_criteria.gke_config](https://registry.terraform.io/providers/humanitec/humanitec/latest/docs/resources/resource_definition_criteria) | resource |
| [humanitec_resource_definition_criteria.hpa](https://registry.terraform.io/providers/humanitec/humanitec/latest/docs/resources/resource_definition_criteria) | resource |
| [humanitec_resource_definition_criteria.ingress](https://registry.terraform.io/providers/humanitec/humanitec/latest/docs/resources/resource_definition_criteria) | resource |
| [humanitec_resource_definition_criteria.k8s_cluster](https://registry.terraform.io/providers/humanitec/humanitec/latest/docs/resources/resource_definition_criteria) | resource |
| [humanitec_resource_definition_criteria.k8s_namespace](https://registry.terraform.io/providers/humanitec/humanitec/latest/docs/resources/resource_definition_criteria) | resource |
| [humanitec_resource_definition_criteria.k8s_service_account](https://registry.terraform.io/providers/humanitec/humanitec/latest/docs/resources/resource_definition_criteria) | resource |
| [humanitec_resource_definition_criteria.redis_in_cluster](https://registry.terraform.io/providers/humanitec/humanitec/latest/docs/resources/resource_definition_criteria) | resource |
| [humanitec_resource_definition_criteria.vertex_ai_iam_member_default](https://registry.terraform.io/providers/humanitec/humanitec/latest/docs/resources/resource_definition_criteria) | resource |
| [humanitec_resource_definition_criteria.workload](https://registry.terraform.io/providers/humanitec/humanitec/latest/docs/resources/resource_definition_criteria) | resource |
| [humanitec_secretstore.default](https://registry.terraform.io/providers/humanitec/humanitec/latest/docs/resources/secretstore) | resource |
| [humanitec_secretstore.primary](https://registry.terraform.io/providers/humanitec/humanitec/latest/docs/resources/secretstore) | resource |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| agent\_public\_key | The public key of the Agent. | `string` | n/a | yes |
| cluster\_access\_gsa\_email | The email of the GSA to access the GKE cluster from Humanitec. | `string` | n/a | yes |
| environment | The environment to use for matching criteria. | `string` | n/a | yes |
| environment\_type | The environment type to use for matching criteria. | `string` | n/a | yes |
| gcp\_wi\_pool\_provider\_name | The Workload Identity Pool Provider name to access the GKE cluster from Humanitec. | `string` | n/a | yes |
| humanitec\_org\_id | ID of the Humanitec Organization to associate resources with. | `string` | n/a | yes |
| k8s\_cluster\_name | The name of the cluster. | `string` | n/a | yes |
| k8s\_loadbalancer | IP address or Host of the load balancer used by the ingress controller. | `string` | n/a | yes |
| k8s\_project\_id | The GCP Project ID the cluster is in. | `string` | n/a | yes |
| k8s\_project\_number | The GCP Project Number the cluster is in. | `string` | n/a | yes |
| k8s\_region | The region the cluster is in. | `string` | n/a | yes |
| operator\_public\_key | The public key of the Operator. | `string` | n/a | yes |
| terraform\_provisioner\_gsa\_email | The email of the GSA to access the GKE cluster from Humanitec. | `string` | n/a | yes |
| prefix | A prefix that will be attached to all IDs created in Humanitec. | `string` | `""` | no |
<!-- END_TF_DOCS -->