deployment.yaml:
  location: namespace
  data:
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: {{ .init.name }}
    spec:
      replicas: 1
      selector:
        matchLabels:
          app: {{ .init.name }}
      template:
        metadata:
          labels:
            app: {{ .init.name }}
        spec:
          automountServiceAccountToken: false
          securityContext:
            fsGroup: 65532
            runAsGroup: 65532
            runAsNonRoot: true
            runAsUser: 65532
            seccompProfile:
              type: RuntimeDefault
          containers:
          - name: {{ .init.name }}
            securityContext:
              allowPrivilegeEscalation: false
              capabilities:
                drop:
                  - ALL
              privileged: false
              readOnlyRootFilesystem: true
            image: redis:7.4.2-alpine
            ports:
            - name: tcp-redis
              containerPort: {{ .init.port }}
            volumeMounts:
            - mountPath: /data
              name: redis-data
          volumes:
          - name: redis-data
            emptyDir: {}
service.yaml:
  location: namespace
  data:
    apiVersion: v1
    kind: Service
    metadata:
      name: {{ .init.name }}
    spec:
      type: ClusterIP
      selector:
        app: {{ .init.name }}
      ports:
      - name: tcp-redis
        port: {{ .init.port }}
        targetPort: tcp-redis