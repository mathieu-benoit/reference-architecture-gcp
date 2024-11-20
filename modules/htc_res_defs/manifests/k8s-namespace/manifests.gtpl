namespace.yaml:
  location: cluster
  data:
    apiVersion: v1
    kind: Namespace
    metadata:
      labels:
        humanitec.io/app: ${context.app.id}
        humanitec.io/env: ${context.env.id}
        pod-security.kubernetes.io/enforce: restricted
        istio-injection: enabled
      name: {{ .init.name }}