resource "kubernetes_namespace" "istio_system" {
  metadata {
    name = "istio-system"
  }
}

resource "kubernetes_config_map" "istio_system" {
  metadata {
    name      = "istio-asm-managed-rapid"
    namespace = kubernetes_namespace.istio_system.metadata.0.name
  }

  data = {
    mesh = <<EOL
defaultConfig:
  image:
    imageType: distroless
discoverySelectors:
- matchLabels:
    istio-injection: enabled
EOL
  }
}

resource "kubernetes_manifest" "default_sidecar" {
  count = var.istio_crds_already_installed ? 1 : 0
  manifest = {
    "apiVersion" = "networking.istio.io/v1beta1"
    "kind"       = "Sidecar"
    "metadata" = {
      "name"      = "default"
      "namespace" = kubernetes_namespace.istio_system.metadata.0.name
    }
    "spec" = {
      "egress" = [{
        "hosts" = ["./*"]
      }]
    }
  }
}

resource "kubernetes_manifest" "default_peer_authentication" {
  count = var.istio_crds_already_installed ? 1 : 0
  manifest = {
    "apiVersion" = "security.istio.io/v1beta1"
    "kind"       = "PeerAuthentication"
    "metadata" = {
      "name"      = "default"
      "namespace" = kubernetes_namespace.istio_system.metadata.0.name
    }
    "spec" = {
      "mtls" = {
        "mode" = "STRICT"
      }
    }
  }
}