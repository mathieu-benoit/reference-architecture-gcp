##########################################
# REQUIRED INPUTS
##########################################

variable "project_id" {
  type        = string
  description = "GCP Project ID to provision resources in."
}


variable "region" {
  type        = string
  description = "GCP Region to provision resources in."
}


variable "humanitec_org_id" {
  type        = string
  description = "ID of the Humanitec Organization to associate resources with."
}

##########################################
# OPTIONAL INPUTS
##########################################

variable "environment" {
  type        = string
  description = "The environment to associate the reference architecture with."
  default     = null
}

variable "environment_type" {
  type        = string
  description = "The environment type to associate the reference architecture with."
  default     = "development"
}

variable "humanitec_prefix" {
  type        = string
  description = "A prefix that will be attached to all IDs created in Humanitec."
  default     = "htc-ref-arch-"
}

variable "gar_repository_id" {
  type        = string
  description = "ID of the Google Artifact Registry repository."
  default     = "htc-ref-arch-cluster"
}

variable "gke_release_channel" {
  description = "GKE Release channel to be used"
  type        = string
  default     = "RAPID"
}

variable "istio_crds_already_installed" {
  description = "Custom resource definitions must be applied before custom resources."
  type        = bool
  default     = false
}