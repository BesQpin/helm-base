
{{- define "base-chart.annotations" -}}
deployment/branch: {{ .Values.annotations.branch }}
deployment/commit: {{ .Values.annotations.commit }}
deployment/deployed-by: {{ .Values.annotations.deployedBy }}
deployment/release-time: {{ now | date "2006.01.02-15.04.05" }}
deployment/utc: {{ .Values.annotations.time }}
{{- end }}


{{/*
Expand the name of the chart.
*/}}
{{- define "base-chart.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}


{{/*
Create chart name and chart version for use by the chart label.
*/}}
{{- define "base-chart.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}


{{- define "base-chart.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}


{{- define "base-chart.ingress.annotations" -}}
{{- with .Values.ingress.annotations }}
{{ toYaml . }}
{{- end }}
{{- end }}


{{/*
Generate the ingress hostname based on namespace label or default. Update example.app to your domain.
*/}}
{{- define "base.ingress.host" -}}
  {{- $namespace := (lookup "v1" "Namespace" "" .Release.Namespace) -}}
  {{- $hostname := "" -}}
  {{- $location := "" -}}
  {{- $environment := "" -}}
  {{- if and $namespace (hasKey $namespace.metadata.labels "location") -}}
    {{- $location = $namespace.metadata.labels.location -}}
  {{- end -}}
  {{- if and $namespace (hasKey $namespace.metadata.labels "environment") -}}
    {{- $environment = $namespace.metadata.labels.environment -}}
  {{- end -}}
  {{- if and $location $environment -}}
    {{- $hostname = printf "%s-%s-%s-example.app" .Release.Name $location $environment -}}
  {{- else if $location -}}
    {{- $hostname = printf "%s-%s-example.app" .Release.Name $location -}}
  {{- else if $environment -}}
    {{- $hostname = printf "%s-%s-example.app" .Release.Name $environment -}}
  {{- else -}}
    {{- $hostname = printf "%s-example.app" .Release.Name -}}
  {{- end -}}
  {{- $hostname -}}
{{- end -}}


{{- define "base-chart.labels" -}}
helm.sh/chart: {{ include "base-chart.chart" . }}
{{ include "base-chart.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Values.image.tag | default .Chart.AppVersion }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}


{{- define "base-chart.selectorLabels" -}}
app.kubernetes.io/name: {{ include "base-chart.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}


{{- define "base-chart.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "base-chart.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}