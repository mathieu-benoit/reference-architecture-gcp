# base
<!-- BEGIN_TF_DOCS -->


### Providers

| Name | Version |
|------|---------|
| google | n/a |
| tls | n/a |

### Modules

| Name | Source | Version |
|------|--------|---------|
| k8s | ../gke | n/a |
| network | ../network | n/a |
| res\_defs | ../htc_res_defs | n/a |

### Resources

| Name | Type |
|------|------|
| [google_compute_address.addr_nat](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_address) | resource |
| [google_project_service.apis](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_service) | resource |
| [tls_private_key.agent](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |
| [tls_private_key.operator](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| environment | The environment to associate the reference architecture with. | `string` | n/a | yes |
| environment\_type | The environment type to associate the reference architecture with. | `string` | n/a | yes |
| gke\_release\_channel | GKE Release channel to be used | `string` | n/a | yes |
| humanitec\_org\_id | ID of the Humanitec Organization to associate resources with. | `string` | n/a | yes |
| project\_id | GCP Project ID to provision resources in. | `string` | n/a | yes |
| project\_number | GCP Project Number to provision resources in. | `string` | n/a | yes |
| region | GCP Region to provision resources in. | `string` | n/a | yes |
| gar\_repository\_id | ID of the Google Artifact Registry repository (not created if empty). | `string` | `null` | no |
| gar\_repository\_location | Location of the Google Artifact Registry repository (required when gar\_repository\_id is set). | `string` | `null` | no |
| gke\_autopilot | Whether GKE Autopilot should be used | `bool` | `true` | no |
| gke\_cluster\_name | The name of the GKE Cluster. Must be unique within the project. | `string` | `"htc-ref-arch-cluster"` | no |
| gke\_subnet\_name | The name of the subnet to allocate IPs for the GKE Cluster from. If vpc\_subnet is set, this must be updated. | `string` | `"htc-ref-arch-subnet"` | no |
| humanitec\_crds\_already\_installed | Custom resource definitions must be applied before custom resources. | `bool` | `false` | no |
| humanitec\_prefix | A prefix that will be attached to all IDs created in Humanitec. | `string` | `""` | no |
| istio\_crds\_already\_installed | Custom resource definitions must be applied before custom resources. | `bool` | `false` | no |
| vpc\_description | VPC Description | `string` | `"VPC for Humanitec Reference Architecture Implementation for GCP. https://github.com/humanitec-architecture/reference-archietcture-gcp"` | no |
| vpc\_name | VPC Name | `string` | `"htc-ref-arch-vpc"` | no |
| vpc\_subnets | List of VPC Subnets | <pre>list(object({<br/>    name                     = string<br/>    description              = string<br/>    ip_cidr_range            = string<br/>    purpose                  = optional(string)<br/>    role                     = optional(string)<br/>    region                   = optional(string)<br/>    private_ip_google_access = optional(bool)<br/>  }))</pre> | <pre>[<br/>  {<br/>    "description": "Subnet that hosts resources provisioned for the Humanitec Reference Architecture Implementation for GCP. https://github.com/humanitec-architecture/reference-archietcture-gcp",<br/>    "ip_cidr_range": "10.128.0.0/20",<br/>    "name": "htc-ref-arch-subnet"<br/>  }<br/>]</pre> | no |

### Outputs

| Name | Description |
|------|-------------|
| gar\_repository\_id | Google Artifact Registry repository id (if created). |
<!-- END_TF_DOCS -->