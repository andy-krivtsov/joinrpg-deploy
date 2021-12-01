{{/*
Create a default app name.
*/}}
{{- define "portal.fullname" -}}
{{- .Values.serviceName | default .Release.Name }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "portal.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "portal.labels" -}}
helm.sh/chart: {{ include "portal.chart" . }}
{{ include "portal.selectorLabels" . }}
app.kubernetes.io/version: {{ .Chart.AppVersion | default .Values.image.tag }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/* 
Selector labels
*/}}
{{- define "portal.selectorLabels" -}}
app.kubernetes.io/name: {{ include "portal.fullname" . }}
{{- end }}


{{/*
  Получить image, собранное из
     .Values.image.registry
     .Values.image.name
     .Values.image.tag
*/}}
{{- define "portal.image" -}}
  {{- printf "%s:%s" (list .Values.image.registry .Values.image.name | join "/") .Values.image.tag }}
{{- end }}

