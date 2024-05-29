# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_cluster
resource "google_container_cluster" "gke" {
  name       = var.cluster_name
  location   = var.region
  network    = var.vpc_name
  subnetwork = var.subnet

  remove_default_node_pool = var.enable_autopilot ? null : true
  initial_node_count       = var.enable_autopilot ? null : 1
  datapath_provider        = "ADVANCED_DATAPATH" # Dataplane V2 (NetworkPolicies) is enabled.

  enable_autopilot = var.enable_autopilot

  # Requried as of version 5.0.0+ of the hashicorp/google provider to allow for a clean destroy
  # Not documented as of this time. See: https://github.com/hashicorp/terraform-provider-google/blob/main/website/docs/r/container_cluster.html.markdown
  deletion_protection = false

  release_channel {
    channel = var.release_channel
  }

  cluster_autoscaling {
    enabled = var.enable_autopilot ? null : true

    auto_provisioning_defaults {
      service_account = google_service_account.gke_nodes.email
      oauth_scopes    = ["https://www.googleapis.com/auth/cloud-platform"]
    }
  }

  fleet {
    project = var.project_id
  }

  master_authorized_networks_config {

    cidr_blocks {
      # Access from this Terraform script to deploy Kubernetes/Helm resources in the GKE cluster:
      cidr_block = "${chomp(data.http.icanhazip.response_body)}/32"
    }

    cidr_blocks {
      # Access from the Humanitec Agent deployed in the GKE cluster:
      cidr_block = "${var.agent_humanitec_egress_ip_address}/32"
    }

    gcp_public_cidrs_access_enabled = false
  }

  ip_allocation_policy {
    cluster_secondary_range_name  = var.ip_allocation_policy.cluster_secondary_range_name
    services_secondary_range_name = var.ip_allocation_policy.services_secondary_range_name
    cluster_ipv4_cidr_block       = var.ip_allocation_policy.cluster_ipv4_cidr_block
    services_ipv4_cidr_block      = var.ip_allocation_policy.services_ipv4_cidr_block
    stack_type                    = var.ip_allocation_policy.stack_type
  }

  node_config {
    machine_type    = var.node_size
    service_account = google_service_account.gke_nodes.email
    oauth_scopes    = ["https://www.googleapis.com/auth/cloud-platform"]
    shielded_instance_config {
      enable_secure_boot          = true
      enable_integrity_monitoring = true
    }
  }

  dynamic "confidential_nodes" {
    for_each = var.enable_autopilot ? [] : [1]
    content {
      enabled = true
    }
  }

  monitoring_config {
    enable_components = ["SYSTEM_COMPONENTS"]
    managed_prometheus {
      enabled = var.enable_autopilot
    }
  }

  logging_config {
    enable_components = ["SYSTEM_COMPONENTS", "WORKLOADS"]
  }

  dynamic "workload_identity_config" {
    # workload identity is enabled by default for Autopilot and there is no
    # need to set the workload pool.
    for_each = var.enable_autopilot ? [] : [1]

    content {
      workload_pool = "${var.project_id}.svc.id.goog"
    }

  }

  private_cluster_config {
    enable_private_endpoint = false
    enable_private_nodes    = true
  }

  security_posture_config {
    mode               = "BASIC"
    vulnerability_mode = "VULNERABILITY_ENTERPRISE"
  }

  lifecycle {
    ignore_changes = [
      node_config # otherwise destroy/recreate with Autopilot...
    ]
  }
}

# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_node_pool
resource "google_container_node_pool" "gke_node_pool" {
  count   = var.enable_autopilot ? 0 : 1
  name    = "primary"
  cluster = google_container_cluster.gke.id

  autoscaling {
    min_node_count = 0
    max_node_count = 4
  }

  node_config {
    machine_type    = var.node_size
    service_account = google_service_account.gke_nodes.email
    oauth_scopes    = ["https://www.googleapis.com/auth/cloud-platform"]

    shielded_instance_config {
      enable_secure_boot          = true
      enable_integrity_monitoring = true
    }
  }
}

# GSA for the GKE nodes
resource "google_service_account" "gke_nodes" {
  account_id  = "${var.cluster_name}-nodes-sa"
  description = "Account used by the GKE nodes"
}
resource "google_project_iam_member" "gke_nodes" {
  for_each = toset([
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter",
    "roles/monitoring.viewer",
    "roles/stackdriver.resourceMetadata.writer",
  ])

  project = var.project_id
  role    = each.key
  member  = "serviceAccount:${google_service_account.gke_nodes.email}"
}

# GSA for the GKE cluster access from Humanitec
resource "google_service_account" "gke_cluster_access" {
  account_id  = var.cluster_name
  description = "Account used by Humanitec to access the GKE cluster"
}
resource "google_project_iam_custom_role" "gke_cluster_access" {
  role_id     = "humanitec.gkeaccess"
  title       = "Humanitec GKE access"
  description = "Can deploy Kubernetes resources from Humanitec to GKE cluster."
  permissions = [
    # GKE get credentials
    "container.clusters.get",
    "container.clusters.getCredentials"
  ]
}
resource "kubernetes_cluster_role" "humanitec_deploy_access" {
  metadata {
    name = "humanitec-deploy-access"
  }

  # Namespaces management
  rule {
    api_groups = [""]
    resources  = ["namespaces"]
    verbs      = ["create", "get", "list", "update", "patch", "delete"]
  }

  # Humanitec's CRs management.
  rule {
    api_groups = ["humanitec.io"]
    resources  = ["resources", "secretmappings", "workloadpatches", "workloads"]
    verbs      = ["create", "get", "list", "update", "patch", "delete", "watch"]
  }

  # Deployment / Workload Status in UI
  rule {
    api_groups = ["batch"]
    resources  = ["jobs"]
    verbs      = ["get", "list"]
  }
  rule {
    api_groups = ["apps"]
    resources  = ["deployments", "statefulsets", "replicasets", "daemonsets"]
    verbs      = ["get", "list"]
  }
  rule {
    api_groups = [""]
    resources  = ["pods"]
    verbs      = ["get", "list"]
  }

  # Container's logs in UI
  rule {
    api_groups = [""]
    resources  = ["pods/log"]
    verbs      = ["get", "list"]
  }

  # To get the active resources (resources outputs)
  rule {
    api_groups = [""]
    resources  = ["configmaps"]
    verbs      = ["get"]
  }

  # For private TF runner (but not needed if self-hosted TF Driver)
  rule {
    api_groups = ["batch"]
    resources  = ["jobs"]
    verbs      = ["create", "delete"]
  }
  rule {
    api_groups = [""]
    resources  = ["secrets"]
    verbs      = ["get", "create", "delete"]
  }
}
resource "kubernetes_cluster_role_binding" "humanitec_deploy_access" {
  metadata {
    name = "humanitec-deploy-access"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.humanitec_deploy_access.metadata.0.name
  }
  subject {
    api_group = "rbac.authorization.k8s.io"
    kind      = "User"
    name      = google_service_account.gke_cluster_access.unique_id
  }
}
resource "google_project_iam_member" "gke_cluster_access" {
  project = var.project_id
  role    = "projects/${var.project_id}/roles/${google_project_iam_custom_role.gke_cluster_access.role_id}"
  member  = "serviceAccount:${google_service_account.gke_cluster_access.email}"
}
resource "google_iam_workload_identity_pool" "gke_cluster_access" {
  workload_identity_pool_id = var.cluster_name
}
resource "google_iam_workload_identity_pool_provider" "gke_cluster_access" {
  display_name                       = var.cluster_name
  workload_identity_pool_id          = google_iam_workload_identity_pool.gke_cluster_access.workload_identity_pool_id
  workload_identity_pool_provider_id = var.cluster_name
  attribute_mapping = {
    "google.subject" = "assertion.sub"
  }
  oidc {
    issuer_uri = "https://idtoken.humanitec.io"
  }
}
resource "google_service_account_iam_member" "gke_cluster_access" {
  service_account_id = google_service_account.gke_cluster_access.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principal://iam.googleapis.com/${google_iam_workload_identity_pool.gke_cluster_access.name}/subject/${var.humanitec_org_id}/${var.cluster_name}"
}