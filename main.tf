terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.1"
    }
    humanitec = {
      source  = "humanitec/humanitec"
      version = "~> 1.0"
    }
  }
  required_version = ">= 1.3.0"
}

provider "google" {
  project = var.project_id
}

provider "humanitec" {
  org_id = var.humanitec_org_id
}



module "base" {
  source                  = "./modules/base"
  project_id              = var.project_id
  region                  = var.region
  humanitec_org_id        = var.humanitec_org_id
  humanitec_prefix        = var.humanitec_prefix
  environment             = var.environment
  environment_type        = var.environment_type
  gar_repository_id       = var.gar_repository_id
  gar_repository_location = var.region
  gke_release_channel     = var.gke_release_channel

  istio_crds_already_installed = var.istio_crds_already_installed

  humanitec_crds_already_installed = var.humanitec_crds_already_installed
}

# Temporary, to be removed as soon as /keys is supported via Terraform.
output "operator_public_key" {
  value     = module.base.operator_public_key
  sensitive = true
}
