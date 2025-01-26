{{ $defaultMaxReplicas := 3 }}
{{ $defaultMinReplicas := 2 }}
{{ $absoluteMaxReplicas := 10 }}
{{ $defaultTargetUtilizationPercent := 80 }}

workload: {{ if regexMatch "modules\\.[a-z0-9-]+\\.externals" ${context.res.id} }}
  {{- index (splitList "." ${context.res.id}) 1 | toRawJson }}
{{- else }}
  {{- cat "A horizontal-pod-autoscaler must be added as a private resource dependency. ID:" ${context.res.id} | fail }}
{{- end }}

maxReplicas: {{ .resource.maxReplicas | default $defaultMaxReplicas | min $absoluteMaxReplicas }}
minReplicas: {{ .resource.minReplicas | default $defaultMinReplicas }}
targetCPUUtilizationPercentage: {{ .resource.targetCPUUtilizationPercentage | default $defaultTargetUtilizationPercent }}