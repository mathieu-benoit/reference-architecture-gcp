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
    annotations = {
      "iam.gke.io/gcp-service-account" = google_service_account.humanitec_runner.email
    }

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

# GSA to provision TF infra
resource "google_service_account" "humanitec_runner" {
  account_id  = "${var.cluster_name}-htcrunner"
  description = "Account used by Humanitec to provision the Google Cloud infrastructure via the Terraform Driver"
}
resource "google_project_iam_member" "humanitec_runner" {
  project = var.project_id
  role    = "roles/owner"
  member  = "serviceAccount:${google_service_account.humanitec_runner.email}"
}
resource "google_service_account_iam_member" "humanitec_runner_wi" {
  service_account_id = google_service_account.humanitec_runner.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.project_id}.svc.id.goog[${kubernetes_namespace.humanitec_runner.metadata.0.name}/${kubernetes_service_account.humanitec_runner.metadata.0.name}]"
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