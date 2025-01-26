# GKE Module

Creates a GKE cluster and installs the ingress-nginx ingress controller in it.

The following is provisioned:
- GKE cluster
- Service Account for accessing the cluster
- External Static IP (to front Load Balancer used by ingress-nginx)
- ingress-nginx provision in-cluster

<!-- BEGIN_TF_DOCS -->


### Providers

| Name | Version |
|------|---------|
| google | n/a |
| helm | n/a |
| http | n/a |
| kubernetes | n/a |

### Resources

| Name | Type |
|------|------|
| [google_artifact_registry_repository.repo](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/artifact_registry_repository) | resource |
| [google_artifact_registry_repository_iam_member.gar_containers_reader](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/artifact_registry_repository_iam_member) | resource |
| [google_compute_address.public_ingress](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_address) | resource |
| [google_container_cluster.gke](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_cluster) | resource |
| [google_container_node_pool.gke_node_pool](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_node_pool) | resource |
| [google_gke_hub_feature.gke_hub_feature](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/gke_hub_feature) | resource |
| [google_gke_hub_feature_membership.gke_hub_feature_membership](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/gke_hub_feature_membership) | resource |
| [google_iam_workload_identity_pool.gke_cluster_access](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/iam_workload_identity_pool) | resource |
| [google_iam_workload_identity_pool_provider.gke_cluster_access](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/iam_workload_identity_pool_provider) | resource |
| [google_project_iam_custom_role.gke_cluster_access](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_custom_role) | resource |
| [google_project_iam_custom_role.secretmanager_readwrite](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_custom_role) | resource |
| [google_project_iam_member.default_secret_store_access_from_operator](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_project_iam_member.default_secret_store_access_from_orchestrator](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_project_iam_member.gke_cluster_access](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_project_iam_member.gke_nodes](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_project_iam_member.humanitec_runner](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_project_iam_member.primary_secret_store_access_from_operator](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_project_iam_member.terraform_runner](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_service_account.gke_cluster_access](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account) | resource |
| [google_service_account.gke_nodes](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account) | resource |
| [google_service_account.humanitec_runner](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account) | resource |
| [google_service_account.terraform_runner](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account) | resource |
| [google_service_account_iam_member.gke_cluster_access](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account_iam_member) | resource |
| [google_service_account_iam_member.humanitec_runner_wi](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account_iam_member) | resource |
| [google_service_account_iam_member.terraform_runner_wi](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account_iam_member) | resource |
| [google_storage_bucket.bucket](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket) | resource |
| [helm_release.humanitec_agent](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.humanitec_operator](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.ingress_nginx](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [kubernetes_cluster_role.humanitec_deploy_access](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/cluster_role) | resource |
| [kubernetes_cluster_role_binding.humanitec_deploy_access](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/cluster_role_binding) | resource |
| [kubernetes_config_map.istio_system](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/config_map) | resource |
| [kubernetes_manifest.default_peer_authentication](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_manifest.default_secret_store_access_from_operator](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_manifest.default_sidecar](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_manifest.nginx_ingress_sidecar](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_manifest.primary_secret_store_access_from_operator](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_namespace.agent-namespace](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace) | resource |
| [kubernetes_namespace.humanitec_operator](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace) | resource |
| [kubernetes_namespace.humanitec_runner](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace) | resource |
| [kubernetes_namespace.ingress_nginx](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace) | resource |
| [kubernetes_namespace.istio_system](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace) | resource |
| [kubernetes_namespace.terraform_runner](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace) | resource |
| [kubernetes_role.humanitec_deploy_runner](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/role) | resource |
| [kubernetes_role.humanitec_private_tf_runner](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/role) | resource |
| [kubernetes_role.humanitec_runner](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/role) | resource |
| [kubernetes_role.terraform_runner](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/role) | resource |
| [kubernetes_role_binding.humanitec_deploy_runner](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/role_binding) | resource |
| [kubernetes_role_binding.humanitec_private_tf_runner](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/role_binding) | resource |
| [kubernetes_role_binding.humanitec_runner](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/role_binding) | resource |
| [kubernetes_role_binding.terraform_runner](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/role_binding) | resource |
| [kubernetes_secret.humanitec_operator](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret) | resource |
| [kubernetes_service_account.humanitec_runner](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service_account) | resource |
| [kubernetes_service_account.terraform_runner](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service_account) | resource |
| [google_client_config.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/client_config) | data source |
| [google_project.project](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/project) | data source |
| [http_http.icanhazip](https://registry.terraform.io/providers/hashicorp/http/latest/docs/data-sources/http) | data source |
| [kubernetes_service.kubernetes](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/data-sources/service) | data source |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| agent\_humanitec\_egress\_ip\_address | The IP address in egress of the Humanitec Agent accessing the GKE cluster. | `string` | n/a | yes |
| agent\_private\_key | The private key of the Agent. | `string` | n/a | yes |
| cluster\_name | The name to assign to the cluster. Must be unique within the project. | `string` | n/a | yes |
| humanitec\_org\_id | ID of the Humanitec Organization to associate resources with. | `string` | n/a | yes |
| operator\_private\_key | The private key of the Operator. | `string` | n/a | yes |
| project\_id | GCP Project ID | `string` | n/a | yes |
| region | GCP Region | `string` | n/a | yes |
| subnet | Subnet name for GKE nodes to be in. | `string` | n/a | yes |
| vpc\_name | VPC Name | `string` | n/a | yes |
| enable\_autopilot | Enable Autopilot cluster instead of standard cluster. | `bool` | `true` | no |
| gar\_repository\_id | The ID of the Google Artifact Registry repository to use for storing Docker images. | `string` | `null` | no |
| gar\_repository\_location | Location of the Google Artifact Registry repository. | `string` | `null` | no |
| humanitec\_crds\_already\_installed | Custom resource definitions must be applied before custom resources. | `bool` | `false` | no |
| ip\_allocation\_policy | Configuration of cluster IP allocation for VPC-native clusters. | <pre>object({<br/>    cluster_secondary_range_name  = optional(string)<br/>    services_secondary_range_name = optional(string)<br/>    cluster_ipv4_cidr_block       = optional(string)<br/>    services_ipv4_cidr_block      = optional(string)<br/>    stack_type                    = optional(string)<br/>  })</pre> | <pre>{<br/>  "cluster_ipv4_cidr_block": "/14",<br/>  "services_ipv4_cidr_block": "/20"<br/>}</pre> | no |
| istio\_crds\_already\_installed | Custom resource definitions must be applied before custom resources. | `bool` | `false` | no |
| node\_size | Size of the GKE nodes. | `string` | `"n2d-standard-4"` | no |
| release\_channel | n/a | `string` | `"REGULAR"` | no |

### Outputs

| Name | Description |
|------|-------------|
| cluster\_access\_gsa\_email | n/a |
| cluster\_access\_wi\_pool\_provider\_name | n/a |
| cluster\_name | n/a |
| cluster\_type | n/a |
| gar\_repository\_id | n/a |
| loadbalancer | n/a |
| name | n/a |
| project\_id | n/a |
| zone | n/a |
<!-- END_TF_DOCS -->