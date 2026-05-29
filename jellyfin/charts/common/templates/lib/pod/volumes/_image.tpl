{{/* Returns Image Volume (Kubernetes 1.31+ volumes.image GA) */}}
{{/* Call this template:
{{ include "tc.v1.common.lib.pod.volume.image" (dict "rootCtx" $ "objectData" $objectData) }}
rootCtx: The root context of the chart.
objectData: The object data to be used to render the volume.

Expected shape:
  type: image
  image:
    reference: ghcr.io/foo/bar:1.0@sha256:...
    pullPolicy: IfNotPresent  # optional
*/}}
{{- define "tc.v1.common.lib.pod.volume.image" -}}
  {{- $rootCtx := .rootCtx -}}
  {{- $objectData := .objectData -}}

  {{- if not $objectData.image -}}
    {{- fail "Persistence - Expected non-empty [image] on [image] type" -}}
  {{- end -}}

  {{- if not $objectData.image.reference -}}
    {{- fail "Persistence - Expected non-empty [image.reference] on [image] type" -}}
  {{- end -}}

- name: {{ $objectData.shortName }}
  image:
    reference: {{ tpl ($objectData.image.reference) $rootCtx }}
    {{- with ($objectData.image.pullPolicy | default "IfNotPresent") }}
    pullPolicy: {{ . }}
    {{- end }}
{{- end -}}
