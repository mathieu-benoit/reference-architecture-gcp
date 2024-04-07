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

resource "google_storage_bucket" "bucket" {
  name          = "${var.cluster_name}-terraform-runner-state"
  location      = var.region
  force_destroy = true
}