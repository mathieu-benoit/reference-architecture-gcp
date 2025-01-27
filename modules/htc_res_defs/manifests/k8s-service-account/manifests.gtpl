service-account.yaml:
  location: namespace
  data:
    apiVersion: v1
    kind: ServiceAccount
    metadata:
      labels:
        humanitec.io/workload: {{ .init.name }}
      name: {{ .init.name }}