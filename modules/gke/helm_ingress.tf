data "kubernetes_service" "kubernetes" {
  metadata {
    name = "kubernetes"
  }
}

resource "kubernetes_namespace" "ingress_nginx" {
  metadata {
    labels = {
      "pod-security.kubernetes.io/enforce" = "restricted"
      "istio-injection"                    = "enabled"
    }

    name = "ingress-nginx"
  }
}

resource "helm_release" "ingress_nginx" {
  name       = "ingress-nginx"
  namespace  = kubernetes_namespace.ingress_nginx.metadata.0.name
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  version    = "4.11.1"
  wait       = true
  timeout    = 300

  set {
    name  = "controller.service.loadBalancerIP"
    value = google_compute_address.public_ingress.address
  }

  set {
    name  = "controller.containerSecurityContext.runAsUser"
    value = 101
  }

  set {
    name  = "controller.containerSecurityContext.runAsGroup"
    value = 101
  }

  set {
    name  = "controller.containerSecurityContext.allowPrivilegeEscalation"
    value = false
  }

  set {
    name  = "controller.containerSecurityContext.readOnlyRootFilesystem"
    value = false
  }

  set {
    name  = "controller.containerSecurityContext.runAsNonRoot"
    value = true
  }

  set_list {
    name  = "controller.containerSecurityContext.capabilities.drop"
    value = ["ALL"]
  }

  set_list {
    name  = "controller.containerSecurityContext.capabilities.add"
    value = ["NET_BIND_SERVICE"]
  }

  set {
    type  = "string"
    name  = "controller.podAnnotations.traffic\\.sidecar\\.istio\\.io/includeInboundPorts"
    value = ""
  }

  set {
    type  = "string"
    name  = "controller.podAnnotations.traffic\\.sidecar\\.istio\\.io/excludeInboundPorts"
    value = "80\\,443"
  }

  set {
    type  = "string"
    name  = "controller.podAnnotations.traffic\\.sidecar\\.istio\\.io/excludeOutboundIPRanges"
    value = "${data.kubernetes_service.kubernetes.spec.0.cluster_ip}/32"
  }
}

resource "kubernetes_manifest" "nginx_ingress_sidecar" {
  count = var.istio_crds_already_installed ? 1 : 0
  manifest = {
    "apiVersion" = "networking.istio.io/v1beta1"
    "kind"       = "Sidecar"
    "metadata" = {
      "name"      = "default"
      "namespace" = kubernetes_namespace.ingress_nginx.metadata.0.name
    }
    "spec" = {
      "egress" = [{
        "hosts" = ["*/*"]
      }]
    }
  }
}