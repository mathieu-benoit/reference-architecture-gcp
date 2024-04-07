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

resource "kubernetes_config_map" "agent-configmap" {
  metadata {
    labels = {
      "app.kubernetes.io/name"     = "humanitec-agent"
      "app.kubernetes.io/instance" = "humanitec-agent"
    }

    name      = "humanitec-agent"
    namespace = kubernetes_namespace.agent-namespace.metadata.0.name
  }

  data = {
    ORGS = var.agent_humanitec_org_id
  }
}

resource "kubernetes_secret" "agent-secret" {
  metadata {
    labels = {
      "app.kubernetes.io/name"     = "humanitec-agent"
      "app.kubernetes.io/instance" = "humanitec-agent"
    }

    name      = "humanitec-agent"
    namespace = kubernetes_namespace.agent-namespace.metadata.0.name
  }

  data = {
    private_key = var.agent_private_key
  }
}

resource "kubernetes_manifest" "agent-deployment" {
  manifest = {
    "apiVersion" = "apps/v1"
    "kind"       = "Deployment"
    "metadata" = {
      "labels" = {
        "app.kubernetes.io/instance" = "humanitec-agent"
        "app.kubernetes.io/name"     = "humanitec-agent"
      }
      "name"      = "humanitec-agent"
      "namespace" = kubernetes_namespace.agent-namespace.metadata.0.name
    }
    "spec" = {
      "selector" = {
        "matchLabels" = {
          "app.kubernetes.io/instance" = "humanitec-agent"
          "app.kubernetes.io/name"     = "humanitec-agent"
        }
      }
      "template" = {
        "metadata" = {
          "labels" = {
            "app.kubernetes.io/instance" = "humanitec-agent"
            "app.kubernetes.io/name"     = "humanitec-agent"
          }
        }
        "spec" = {
          "containers" = [
            {
              "env" = [
                {
                  "name" = "CONNECTION_ID"
                  "valueFrom" = {
                    "fieldRef" = {
                      "fieldPath" = "metadata.name"
                    }
                  }
                },
              ]
              "envFrom" = [
                {
                  "configMapRef" = {
                    "name" = kubernetes_config_map.agent-configmap.metadata.0.name
                  }
                },
              ]
              "image" = "registry.humanitec.io/public/humanitec-agent-client:1.1.7"
              "name"  = "humanitec-agent"
              "resources" = {
                "limits" = {
                  "cpu"               = "250m"
                  "memory"            = "512Mi"
                  "ephemeral-storage" = "1Gi"
                }
                "requests" = {
                  "cpu"               = "250m"
                  "memory"            = "512Mi"
                  "ephemeral-storage" = "1Gi"
                }
              }
              "securityContext" = {
                "allowPrivilegeEscalation" = false
                "capabilities" = {
                  "drop" = [
                    "ALL"
                  ]
                }
                "privileged"             = false
                "readOnlyRootFilesystem" = true
              }
              "volumeMounts" = [
                {
                  "mountPath" = "/keys"
                  "name"      = "agentmount"
                  "readOnly"  = true
                },
              ]
            },
          ]
          "securityContext" = {
            "fsGroup"             = 1000
            "fsGroupChangePolicy" = "Always"
            "runAsGroup"          = 1000
            "runAsUser"           = 1000
            "runAsNonRoot"        = true
            "seccompProfile" = {
              "type" = "RuntimeDefault"
            }
          }
          "volumes" = [
            {
              "name" = "agentmount"
              "projected" = {
                "sources" = [
                  {
                    "secret" = {
                      "items" = [
                        {
                          "key"  = "private_key"
                          "mode" = 384
                          "path" = "private_key.pem"
                        },
                      ]
                      "name" = kubernetes_secret.agent-secret.metadata.0.name
                    }
                  },
                ]
              }
            },
          ]
        }
      }
    }
  }
}