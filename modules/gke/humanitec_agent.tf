resource "kubernetes_namespace" "agent-namespace" {
  metadata {
    labels = {
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
  version    = "1.2.9"
  wait       = true
  timeout    = 300

  set {
    name  = "image.tag"
    value = "1.8.4"
  }

  set {
    name  = "humanitec.org"
    value = var.humanitec_org_id
  }

  set {
    name  = "podSecurityContext.fsGroup"
    value = "65532"
  }

  set {
    name  = "podSecurityContext.runAsGroup"
    value = "65532"
  }

  set {
    name  = "podSecurityContext.runAsUser"
    value = "65532"
  }

  set_sensitive {
    name  = "humanitec.privateKey"
    value = var.agent_private_key
  }

  set {
    name  = "image.repository"
    value = "ghcr.io/humanitec/agent"
  }
}