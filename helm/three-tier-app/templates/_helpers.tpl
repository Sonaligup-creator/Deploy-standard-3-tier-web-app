{{- define "three-tier-app.name" -}}
{{- default .Chart.Name .Values.global.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "three-tier-app.fullname" -}}
{{- if .Values.global.fullnameOverride -}}
{{- .Values.global.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name (include "three-tier-app.name" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "three-tier-app.componentName" -}}
{{- printf "%s-%s" (include "three-tier-app.fullname" .root) .component | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "three-tier-app.tierServiceName" -}}
{{- printf "%s-%s-%s" .root.Release.Name .tier .tier | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "three-tier-app.labels" -}}
app.kubernetes.io/name: {{ include "three-tier-app.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
helm.sh/chart: {{ printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" }}
{{- end -}}

{{- define "three-tier-app.frontendPath" -}}
{{- default "/" .Values.global.paths.frontend -}}
{{- end -}}

{{- define "three-tier-app.apiPath" -}}
{{- default "/api" .Values.global.paths.api -}}
{{- end -}}
