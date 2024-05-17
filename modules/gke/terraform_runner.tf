resource "kubernetes_namespace" "terraform-runner" {
  metadata {
    labels = {
      "app.kubernetes.io/name"             = "humanitec-terraform-runner"
      "app.kubernetes.io/instance"         = "humanitec-terraform-runner"
      "pod-security.kubernetes.io/enforce" = "restricted"
    }

    name = "humanitec-terraform-runner"
  }
}

resource "kubernetes_service_account" "terraform-runner" {
  metadata {
    annotations = {
      "iam.gke.io/gcp-service-account" = google_service_account.terraform_runner.email
    }

    labels = {
      "app.kubernetes.io/name"     = "humanitec-terraform-runner"
      "app.kubernetes.io/instance" = "humanitec-terraform-runner"
    }

    name      = "humanitec-terraform-runner"
    namespace = kubernetes_namespace.terraform-runner.metadata.0.name
  }
}

resource "kubernetes_role" "secrets" {
  metadata {
    name      = "secrets"
    namespace = kubernetes_namespace.terraform-runner.metadata.0.name
  }

  rule {
    api_groups = [""]
    resources  = ["secrets"]
    verbs      = ["create", "delete", "get", "list", "update", "deletecollection"]
  }
}

# Need leases if you use backend "kubernetes"
resource "kubernetes_role" "leases" {
  metadata {
    name      = "leases"
    namespace = kubernetes_namespace.terraform-runner.metadata.0.name
  }

  rule {
    api_groups = ["coordination.k8s.io"]
    resources  = ["leases"]
    verbs      = ["create", "get", "list", "update", "watch"]
  }
}

resource "kubernetes_role_binding" "secrets" {
  metadata {
    name      = "secrets"
    namespace = kubernetes_namespace.terraform-runner.metadata.0.name
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = "secrets"
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.terraform-runner.metadata.0.name
    namespace = kubernetes_namespace.terraform-runner.metadata.0.name
  }
}

resource "kubernetes_role_binding" "leases" {
  metadata {
    name      = "leases"
    namespace = kubernetes_namespace.terraform-runner.metadata.0.name
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = "leases"
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.terraform-runner.metadata.0.name
    namespace = kubernetes_namespace.terraform-runner.metadata.0.name
  }
}

# TF state
resource "google_storage_bucket" "bucket" {
  name          = "${var.cluster_name}-terraform-runner-state"
  location      = var.region
  force_destroy = true
}

# GSA to provision TF infra
resource "google_service_account" "terraform_runner" {
  account_id  = "${var.cluster_name}-tf-runner"
  description = "Account used by Humanitec to provision the Google Cloud infrastructure via the Terraform Driver"
}
resource "google_project_iam_member" "terraform_runner" {
  project = var.project_id
  role    = "roles/owner"
  member  = "serviceAccount:${google_service_account.terraform_runner.email}"
}
resource "google_service_account_iam_member" "terraform_runner_wi" {
  service_account_id = google_service_account.terraform_runner.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.project_id}.svc.id.goog[${kubernetes_namespace.terraform-runner.metadata.0.name}/${kubernetes_service_account.terraform-runner.metadata.0.name}]"
}

# Credentials of the GKE cluster for the TF runner
resource "google_secret_manager_secret" "terraform_runner_cluster_credentials" {
  secret_id = "terraform-runner-cluster-credentials"

  replication {
    auto {}
  }
}
resource "google_secret_manager_secret_version" "terraform_runner_cluster_credentials" {
  secret = google_secret_manager_secret.terraform_runner_cluster_credentials.id

  secret_data = base64decode(google_service_account_key.gke_cluster_access_key.private_key)
}