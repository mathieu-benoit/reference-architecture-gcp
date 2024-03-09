resource "humanitec_resource_definition" "k8s_cluster" {
  driver_type = "humanitec/k8s-cluster-gke"
  id          = "${var.prefix}cluster"
  name        = "${var.prefix}cluster"
  type        = "k8s-cluster"

  driver_inputs = {
    values_string = jsonencode({
      "name"         = var.k8s_cluster_name
      "loadbalancer" = var.k8s_loadbalancer
      "project_id"   = var.k8s_project_id
      "zone"         = var.k8s_region
    }),
    secrets_string = jsonencode({
      "credentials" = var.k8s_credentials
    })
  }
}

resource "humanitec_resource_definition_criteria" "k8s_cluster" {
  resource_definition_id = humanitec_resource_definition.k8s_cluster.id
  env_id                 = var.environment
  env_type               = var.environment_type

}


resource "humanitec_resource_definition" "k8s_namespace" {
  driver_type = "humanitec/template"
  id          = "${var.prefix}namespace"
  name        = "${var.prefix}namespace"
  type        = "k8s-namespace"

  driver_inputs = {
    values_string = jsonencode({
      templates = {
        init      = "name: $${context.app.id}-$${context.env.id}"
        manifests = <<EOL
namespace.yaml:
  location: cluster
  data:
    apiVersion: v1
    kind: Namespace
    metadata:
      labels:
        pod-security.kubernetes.io/enforce: restricted
      name: {{ .init.name }}
EOL
        outputs   = "namespace: {{ .init.name }}"
      }
    })
  }
}

resource "humanitec_resource_definition_criteria" "k8s_namespace" {
  resource_definition_id = humanitec_resource_definition.k8s_namespace.id
  env_id                 = var.environment
  env_type               = var.environment_type
}

resource "humanitec_resource_definition" "workload" {
  driver_type = "humanitec/template"
  id          = "${var.prefix}workload"
  name        = "${var.prefix}workload"
  type        = "workload"

  driver_inputs = {
    values_string = jsonencode({
      templates = {
        init      = ""
        manifests = ""
        outputs   = <<EOL
update:
  - op: add
    path: /spec/automountServiceAccountToken
    value: false
  - op: add
    path: /spec/securityContext
    value:
      fsGroup: 1000
      runAsGroup: 1000
      runAsNonRoot: true
      runAsUser: 1000
      seccompProfile:
        type: RuntimeDefault
  {{- range $containerId, $value := .resource.spec.containers }}
  - op: add
    path: /spec/containers/{{ $containerId }}/securityContext
    value:
      allowPrivilegeEscalation: false
      capabilities:
        drop:
          - ALL
      privileged: false
      readOnlyRootFilesystem: true
  {{- end }}
EOL
      }
    })
  }
}

resource "humanitec_resource_definition_criteria" "workload" {
  resource_definition_id = humanitec_resource_definition.workload.id
  env_id                 = var.environment
  env_type               = var.environment_type
}
