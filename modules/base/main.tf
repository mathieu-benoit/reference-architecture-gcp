# ######################################################################
# # Enabling required APIs in Google Cloud project
# ######################################################################
resource "google_project_service" "apis" {
  for_each = toset([
    "artifactregistry.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "compute.googleapis.com",
    "container.googleapis.com",
    "containerscanning.googleapis.com",
    "containeranalysis.googleapis.com"
  ])

  service = each.key

  disable_on_destroy = false
}

# ######################################################################
# # NETWORKING MODULE: VPC
# ######################################################################
module "network" {
  source          = "../network"
  project_id      = var.project_id
  region          = var.region
  vpc_name        = var.vpc_name
  vpc_description = var.vpc_description
  subnets         = [for s in var.vpc_subnets : merge(s, { region = s.region == null ? var.region : s.region })]
}

# ######################################################################
# # Create a Private/Public key for the Humanitec Agent
# ######################################################################

resource "tls_private_key" "agent" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# ######################################################################
# # KUBERNETES MODULE: GKE
# ######################################################################
module "k8s" {

  source       = "../gke"
  project_id   = var.project_id
  region       = var.region
  cluster_name = var.gke_cluster_name
  # Ensures a dependency on module.network AND that id in var.gke_subnet_name exists in the subnets supplied in var.vpc_subnets
  subnet           = { for s in module.network.subnet_names : s => s if s == var.gke_subnet_name }[var.gke_subnet_name]
  vpc_name         = var.vpc_name
  enable_autopilot = var.gke_autopilot

  gar_repository_id       = var.gar_repository_id
  gar_repository_location = var.gar_repository_location

  agent_humanitec_org_id = var.humanitec_org_id
  agent_private_key      = tls_private_key.agent.private_key_pem
}

# ######################################################################
# # HUMANITEC MODULE
# ######################################################################
module "res_defs" {
  source           = "../htc_res_defs"
  k8s_cluster_name = module.k8s.cluster_name
  k8s_loadbalancer = module.k8s.loadbalancer
  k8s_region       = var.region
  k8s_project_id   = var.project_id
  k8s_credentials  = module.k8s.credentials
  environment      = var.environment
  environment_type = var.environment_type
  prefix           = var.humanitec_prefix
  agent_public_key = tls_private_key.agent.public_key_pem
}
