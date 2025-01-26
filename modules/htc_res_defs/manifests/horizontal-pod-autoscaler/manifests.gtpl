hpa.yaml:
  location: namespace
  data:
    apiVersion: autoscaling/v2
    kind: HorizontalPodAutoscaler
    metadata:
      name: {{ .init.workload }}-hpa
    spec:
      maxReplicas: {{ .init.maxReplicas }}
      metrics:
      - resource:
          name: cpu
          target:
            averageUtilization: {{ .init.targetCPUUtilizationPercentage }}
            type: Utilization
        type: Resource
      minReplicas: {{ .init.minReplicas }}
      scaleTargetRef:
        apiVersion: apps/v1
        kind: Deployment
        name: {{ .init.workload }}