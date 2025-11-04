{{- define "katya-rechain-mesh.fullname" -}}
{{- .Chart.Name -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "katya-rechain-mesh.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "katya-rechain-mesh.labels" -}}
helm.sh/chart: {{ include "katya-rechain-mesh.chart" . }}
{{ include "katya-rechain-mesh.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
Selector labels
*/}}
{{- define "katya-rechain-mesh.selectorLabels" -}}
app.kubernetes.io/name: {{ include "katya-rechain-mesh.fullname" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "katya-rechain-mesh.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (include "katya-rechain-mesh.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}
