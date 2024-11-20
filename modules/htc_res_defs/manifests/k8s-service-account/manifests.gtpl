service-account.yaml:
  location: namespace
  data:
    apiVersion: v1
    kind: ServiceAccount
    metadata:
      labels:
        humanitec.io/workload: {{ .init.name }}
        humanitec.io/app: ${context.app.id}
        humanitec.io/env: ${context.env.id}
      name: {{ .init.name }}