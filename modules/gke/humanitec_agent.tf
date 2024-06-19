resource "kubernetes_namespace" "agent-namespace" {
  metadata {
    labels = {
      "app.kubernetes.io/name"             = "humanitec-agent"
      "app.kubernetes.io/instance"         = "humanitec-agent"
      "pod-security.kubernetes.io/enforce" = "restricted"
    }

    name = "humanitec-agent"
  }
}

resource "helm_release" "humanitec_agent" {
  name       = "humanitec-agent"
  namespace  = kubernetes_namespace.agent-namespace.metadata.0.name
  repository = "oci://ghcr.io/humanitec/charts"
  chart      = "humanitec-agent"
  version    = "1.1.1"
  wait       = true
  timeout    = 300

  set {
    name  = "humanitec.org"
    value = var.humanitec_org_id
  }

  set {
    name  = "humanitec.privateKey"
    value = var.agent_private_key
  }

  set {
    name  = "image.repository"
    value = "ghcr.io/humanitec/agent"
  }

  set {
    name  = "image.tag"
    value = "1.5.2"
  }
}