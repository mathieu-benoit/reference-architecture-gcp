resource "kubernetes_namespace" "humanitec_runner" {
  metadata {
    labels = {
      "pod-security.kubernetes.io/enforce" = "restricted"
    }

    name = "humanitec-runner"
  }
}

resource "kubernetes_service_account" "humanitec_runner" {
  metadata {
    name      = "humanitec-runner"
    namespace = kubernetes_namespace.humanitec_runner.metadata.0.name
  }
}

resource "kubernetes_role" "humanitec_runner" {
  metadata {
    name      = "humanitec_runner"
    namespace = kubernetes_namespace.humanitec_runner.metadata.0.name
  }

  rule {
    api_groups = [""]
    resources  = ["secrets", "configmaps"]
    verbs      = ["create"]
  }

  # Need more below if you use default backend "kubernetes"
  rule {
    api_groups = [""]
    resources  = ["secrets"]
    verbs      = ["delete", "get", "list", "update", "deletecollection"]
  }
  rule {
    api_groups = ["coordination.k8s.io"]
    resources  = ["leases"]
    verbs      = ["create", "get", "list", "update", "watch"]
  }
}

resource "kubernetes_role_binding" "humanitec_runner" {
  metadata {
    name      = "humanitec_runner"
    namespace = kubernetes_namespace.humanitec_runner.metadata.0.name
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role.humanitec_runner.metadata.0.name
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.humanitec_runner.metadata.0.name
    namespace = kubernetes_namespace.humanitec_runner.metadata.0.name
  }
}

# GKE's Cloud Account to deploy Humanitec Runner
resource "kubernetes_role" "humanitec_deploy_runner" {
  metadata {
    name      = "humanitec-deploy-runner"
    namespace = kubernetes_namespace.humanitec_runner.metadata.0.name
  }

  rule {
    api_groups = ["batch"]
    resources  = ["jobs"]
    verbs      = ["create", "delete"]
  }
  rule {
    api_groups = [""]
    resources  = ["configmaps", "secrets"]
    verbs      = ["get", "create", "delete", "deletecollection"]
  }
  rule {
    api_groups = [""]
    resources  = ["pods", "events"]
    verbs      = ["list"]
  }
  rule {
    api_groups = [""]
    resources  = ["pods/log"]
    verbs      = ["get"]
  }
}
resource "kubernetes_role_binding" "humanitec_deploy_runner" {
  metadata {
    name      = "humanitec-deploy-runner"
    namespace = kubernetes_namespace.humanitec_runner.metadata.0.name
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role.humanitec_deploy_runner.metadata.0.name
  }
  subject {
    api_group = "rbac.authorization.k8s.io"
    kind      = "User"
    name      = google_service_account.gke_cluster_access.email
  }
}

# GSA to provision TF infra
resource "google_service_account" "humanitec_runner_deploy_terraform" {
  account_id  = "${var.cluster_name}-htcrunner"
  description = "Account used by Humanitec to provision the Google Cloud infrastructure via the Terraform"
}
resource "google_service_account_iam_member" "humanitec_runner_deploy_terraform_for_wi" {
  service_account_id = google_service_account.humanitec_runner_deploy_terraform.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principal://iam.googleapis.com/${google_iam_workload_identity_pool.gke_cluster_access.name}/subject/${var.humanitec_org_id}/${google_service_account.humanitec_runner_deploy_terraform.account_id}"
}
resource "google_project_iam_member" "humanitec_runner_deploy_terraform_for_gcs" {
  project = var.project_id
  role    = "roles/storage.admin"
  member  = "serviceAccount:${google_service_account.humanitec_runner_deploy_terraform.email}"
}
resource "google_project_iam_member" "humanitec_runner_deploy_terraform_for_vertex_ai" {
  project = var.project_id
  role    = "roles/serviceusage.serviceUsageAdmin"
  member  = "serviceAccount:${google_service_account.humanitec_runner_deploy_terraform.email}"
}
