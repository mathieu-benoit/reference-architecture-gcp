locals {
  # FIXME - replace with datasource
  humanitec_operator_k8s_sa_name = "humanitec-operator-controller-manager"
}

resource "kubernetes_namespace" "humanitec_operator" {
  metadata {
    labels = {
      "app.kubernetes.io/name"             = "humanitec-operator"
      "app.kubernetes.io/instance"         = "humanitec-operator"
      "pod-security.kubernetes.io/enforce" = "restricted"
    }

    name = "humanitec-operator"
  }
}

resource "helm_release" "humanitec_operator" {
  name       = "humanitec-operator"
  namespace  = kubernetes_namespace.humanitec_operator.metadata.0.name
  repository = "oci://ghcr.io/humanitec/charts"
  chart      = "humanitec-operator"
  version    = "0.1.10"
  wait       = true
  timeout    = 300
}

resource "kubernetes_secret" "humanitec_operator" {
  metadata {
    name      = "humanitec-operator-private-key"
    namespace = kubernetes_namespace.humanitec_operator.metadata.0.name
  }

  data = {
    privateKey              = var.operator_private_key
    humanitecOrganisationID = var.humanitec_org_id
  }
}

# Access from Humanitec Operator by the default store
resource "google_project_iam_custom_role" "secretmanager_readwrite" {
  role_id     = "secretmanager.readwrite"
  title       = "Secret Reader/Writer"
  description = "Can create new and update existing secrets and read them"
  permissions = [
    "secretmanager.secrets.create",
    "secretmanager.secrets.delete",
    "secretmanager.secrets.update",
    "secretmanager.versions.list",
    "secretmanager.versions.add",
    "secretmanager.versions.access"
  ]
}
resource "google_project_iam_member" "default_secret_store_access_from_operator" {
  project = var.project_id
  role    = "projects/${var.project_id}/roles/${google_project_iam_custom_role.secretmanager_readwrite.role_id}"
  member  = "principal://iam.googleapis.com/projects/${data.google_project.project.number}/locations/global/workloadIdentityPools/${var.project_id}.svc.id.goog/subject/ns/${kubernetes_namespace.humanitec_operator.metadata.0.name}/sa/${local.humanitec_operator_k8s_sa_name}"
}
resource "kubernetes_manifest" "default_secret_store_access_from_operator" {
  count = var.humanitec_crds_already_installed ? 1 : 0
  manifest = {
    "apiVersion" = "humanitec.io/v1alpha1"
    "kind"       = "SecretStore"
    "metadata" = {
      "name"      = "default"
      "namespace" = kubernetes_namespace.humanitec_operator.metadata.0.name
      "labels" = {
        "app.humanitec.io/default-store" = "true"
      }
    }
    "spec" = {
      "gcpsm" = {
        "projectID" = "${var.project_id}"
        "auth"      = {}
      }
    }
  }
}

# Access from Humanitec Orchestrator by the default store
resource "google_project_iam_member" "default_secret_store_access_from_orchestrator" {
  project = var.project_id
  role    = "roles/secretmanager.admin"
  member  = "principal://iam.googleapis.com/projects/${data.google_project.project.number}/locations/global/workloadIdentityPools/${var.project_id}.svc.id.goog/subject/ns/${kubernetes_namespace.humanitec_operator.metadata.0.name}/sa/${local.humanitec_operator_k8s_sa_name}"
}

# Access from Humanitec Operator by the primary store
resource "google_project_iam_member" "primary_secret_store_access_from_operator" {
  project = var.project_id
  role    = "roles/secretmanager.secretAccessor"
  member  = "principal://iam.googleapis.com/projects/${data.google_project.project.number}/locations/global/workloadIdentityPools/${var.project_id}.svc.id.goog/subject/ns/${kubernetes_namespace.humanitec_operator.metadata.0.name}/sa/${local.humanitec_operator_k8s_sa_name}"
}
resource "kubernetes_manifest" "primary_secret_store_access_from_operator" {
  count = var.humanitec_crds_already_installed ? 1 : 0
  manifest = {
    "apiVersion" = "humanitec.io/v1alpha1"
    "kind"       = "SecretStore"
    "metadata" = {
      "name"      = "primary"
      "namespace" = kubernetes_namespace.humanitec_operator.metadata.0.name
    }
    "spec" = {
      "gcpsm" = {
        "projectID" = "${var.project_id}"
        "auth"      = {}
      }
    }
  }
}