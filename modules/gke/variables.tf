variable "project_id" {
  type        = string
  description = "GCP Project ID"
}

variable "region" {
  type        = string
  description = "GCP Region"
}

variable "vpc_name" {
  type        = string
  description = "VPC Name"
}

variable "subnet" {
  type        = string
  description = "Subnet name for GKE nodes to be in."
}

variable "cluster_name" {
  description = "The name to assign to the cluster. Must be unique within the project."
  type        = string
}



# Defaults to /14 for pods and /20 for services as defined here: https://cloud.google.com/kubernetes-engine/docs/concepts/alias-ips#defaults_limits
variable "ip_allocation_policy" {
  description = "Configuration of cluster IP allocation for VPC-native clusters."
  type = object({
    cluster_secondary_range_name  = optional(string)
    services_secondary_range_name = optional(string)
    cluster_ipv4_cidr_block       = optional(string)
    services_ipv4_cidr_block      = optional(string)
    stack_type                    = optional(string)
  })
  default = {
    cluster_ipv4_cidr_block  = "/14"
    services_ipv4_cidr_block = "/20"
  }
}

variable "enable_autopilot" {
  description = "Enable Autopilot cluster instead of standard cluster."
  type        = bool
  default     = true
}


variable "release_channel" {
  type    = string
  default = "REGULAR"
}

variable "node_size" {
  description = "Size of the GKE nodes."
  type        = string
  default     = "n2d-standard-4"
}

variable "gar_repository_id" {
  description = "The ID of the Google Artifact Registry repository to use for storing Docker images."
  type        = string
  default     = null
}

variable "gar_repository_location" {
  description = "Location of the Google Artifact Registry repository."
  type        = string
  default     = null
}

variable "agent_humanitec_org_id" {
  type        = string
  description = "ID of the Humanitec Organization to associate resources with."
}

variable "agent_private_key" {
  description = "The private key of the Agent."
  type        = string
  sensitive   = true
}

variable "agent_humanitec_egress_ip_address" {
  description = "The IP address in egress of the Humanitec Agent accessing the GKE cluster."
  type        = string
}

# Custom resource definitions must be applied before custom resources. 
# This is because the provider queries the Kubernetes API for the OpenAPI specification for the resource supplied in the manifest attribute.
# If the CRD doesn’t exist in the OpenAPI specification during plan time then Terraform can’t use it to create custom resources.
variable "istio_crds_already_installed" {
  description = "Custom resource definitions must be applied before custom resources."
  type        = bool
  default     = false
}