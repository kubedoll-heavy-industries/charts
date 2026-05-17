{{/*
Expand the name of the chart.
*/}}
{{- define "terraria-tshock.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a fully qualified app name (release-name-chart-name, truncated to 63).
If the release name already contains the chart name, just use the release name.
*/}}
{{- define "terraria-tshock.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{- define "terraria-tshock.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Standard labels applied to every resource.
*/}}
{{- define "terraria-tshock.labels" -}}
helm.sh/chart: {{ include "terraria-tshock.chart" . }}
{{ include "terraria-tshock.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- with .Values.extraLabels }}
{{ toYaml . }}
{{- end }}
{{- end }}

{{/*
Selector labels — used by the Service and StatefulSet selectors; MUST be
stable across upgrades or pods become orphans. Don't add anything here that
varies between releases.
*/}}
{{- define "terraria-tshock.selectorLabels" -}}
app.kubernetes.io/name: {{ include "terraria-tshock.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
TShock CLI args computed from .Values.server. Returns a YAML list suitable for
splicing into a StatefulSet container `args:` field. Validates that worldName
is set (required to bypass Terraria's interactive prompt).
*/}}
{{- define "terraria-tshock.args" -}}
{{- if not .Values.server.worldName -}}
{{- fail "terraria-tshock: .Values.server.worldName is required (used for -world absolute path; without it Terraria falls through to the interactive 'n=New, d=Delete' prompt at first boot)" -}}
{{- end -}}
{{- $worldSafe := regexReplaceAll "[^A-Za-z0-9_-]+" .Values.server.worldName "_" -}}
- "-ignoreversion"
- "-configpath"
- "/serverdata/serverfiles/tshock"
- "-logpath"
- "/serverdata/serverfiles/logs"
- "-world"
- "/serverdata/serverfiles/worlds/{{ $worldSafe }}.wld"
- "-worldselectpath"
- "/serverdata/serverfiles/worlds"
- "-worldname"
- {{ .Values.server.worldName | quote }}
- "-autocreate"
- {{ .Values.server.worldSize | quote }}
- "-port"
- {{ .Values.service.port | quote }}
- "-maxplayers"
- {{ .Values.server.maxPlayers | quote }}
{{- with .Values.server.password }}
- "-pass"
- {{ . | quote }}
{{- end }}
{{- with .Values.server.difficulty }}
- "-difficulty"
- {{ . | quote }}
{{- end }}
{{- if .Values.server.secure }}
- "-secure"
{{- end }}
{{- with .Values.server.language }}
- "-lang"
- {{ . | quote }}
{{- end }}
{{- range .Values.server.gameParams }}
- {{ . | quote }}
{{- end }}
{{- end }}
