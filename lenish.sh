#!/usr/bin/env bash
set -euo pipefail

# A Lens-like CLI navigator for Kubernetes using fzf.
# Browse: Category -> Kind -> Namespace -> Resource
# Actions: describe, logs (pods), edit, delete, YAML view, copy name

BAT="bat --style=plain --paging=never"
K_GET="kubectl get"
K_DESC="kubectl describe"
K_LOGS="kubectl logs"
K_EDIT="kubectl edit"
K_DEL="kubectl delete"

# Category -> kinds map (adjust to taste)
declare -A KINDS
KINDS["Workloads"]="deploy sts ds job cronjob po"
KINDS["Networking"]="svc ingress endpoints"
KINDS["Config & Policy"]="cm secret hpa pdb networkpolicy"
KINDS["Storage"]="pvc pv sc"
KINDS["RBAC"]="sa role rolebinding clusterrole clusterrolebinding"
KINDS["Nodes & Cluster"]="node ns crd apiservice"

pick_category() {
  printf '%s\n' "${!KINDS[@]}" | sort | fzf --header="Select Category  ⌘: / to fuzzy search" \
    --preview-window=hidden
}

list_kinds_for_category() {
  local cat="$1"
  for k in ${KINDS[$cat]}; do
    echo "$k"
  done | fzf --header="Select Kind (resource type)" \
    --preview "kubectl api-resources | grep -E '(^| ){q}( |$)' || true" \
    --preview-window=right,60%
}

pick_namespace() {
  {
    echo "All namespaces"
    $K_GET ns --no-headers 2>/dev/null | awk '{print $1}'
  } | fzf --header="Select Namespace" --preview-window=hidden
}

# Build the kubectl namespace flag
ns_flag() {
  local ns="$1"
  if [[ "$ns" == "All namespaces" ]]; then
    echo "--all-namespaces"
  else
    echo "-n $ns"
  fi
}

resource_list_cmd() {
  local kind="$1" ns="$2"
  local nsf
  nsf="$(ns_flag "$ns")"
  # Normalize kind aliases for kubectl get output name
  $K_GET $nsf "$kind" -o name 2>/dev/null | sed 's#.*/##' || true
}

is_pod_kind() {
  [[ "$1" == "po" || "$1" == "pod" || "$1" == "pods" ]]
}

preview_cmd() {
  local kind="$1" ns="$2"
  local nsf
  nsf="$(ns_flag "$ns")"
  # Show describe (fast) or yaml (pretty) in preview
  # Try describe first; if it fails, fallback to YAML
  echo "if kubectl get $nsf $kind {1} &>/dev/null; then \
        $K_DESC $nsf $kind {1} || kubectl get $nsf $kind {1} -o yaml | $BAT -l yaml; \
      else \
        echo 'Not found (race?)'; \
      fi"
}

actions_help() {
  echo "
ENTER: describe    CTRL-L: logs (pods)    CTRL-Y: copy name
CTRL-E: edit       CTRL-D: delete         CTRL-O: YAML (open)
ESC: quit
"
}

open_yaml() {
  local kind="$1" ns="$2" name="$3"
  local nsf
  nsf="$(ns_flag "$ns")"
  kubectl get $nsf "$kind" "$name" -o yaml | ${PAGER:-less}
}

do_logs() {
  local ns="$1" name="$2"
  local nsf
  nsf="$(ns_flag "$ns")"
  $K_LOGS $nsf "$name" --tail=200 -f
}

do_edit() {
  local kind="$1" ns="$2" name="$3"
  local nsf
  nsf="$(ns_flag "$ns")"
  $K_EDIT $nsf "$kind" "$name"
}

do_delete() {
  local kind="$1" ns="$2" name="$3"
  local nsf
  nsf="$(ns_flag "$ns")"
  read -p "Delete $kind/$name in '$ns'? [y/N] " ans
  if [[ "${ans:-N}" =~ ^[Yy]$ ]]; then
    $K_DEL $nsf "$kind" "$name"
    read -p "Deleted. Press Enter to continue..." _
  fi
}

do_describe() {
  local kind="$1" ns="$2" name="$3"
  local nsf
  nsf="$(ns_flag "$ns")"
  $K_DESC $nsf "$kind" "$name" | ${PAGER:-less -R}
}

main_loop() {
  while true; do
    clear
    echo "Lens-ish K8s Navigator"
    echo "======================"
    echo
    local category
    category="$(pick_category)" || exit 0
    local kind
    kind="$(list_kinds_for_category "$category")" || continue
    local ns
    ns="$(pick_namespace)" || continue

    while true; do
      clear
      echo "Category: $category  |  Kind: $kind  |  Namespace: $ns"
      actions_help
      local preview
      preview="$(preview_cmd "$kind" "$ns")"

      local selection
      selection="$(
        resource_list_cmd "$kind" "$ns" |
          fzf --header="Select resource (fuzzy to filter)" \
            --preview="$preview" \
            --preview-window=right,70% \
            --bind "enter:execute-silent(echo -n {1} > /tmp/fzf_k_name)+abort" \
            --bind "ctrl-y:execute-silent(echo -n {1} | pbcopy)+reload(echo {q})" \
            --bind "ctrl-o:execute-silent(echo yaml:{1} > /tmp/fzf_k_action)+abort" \
            --bind "ctrl-e:execute-silent(echo edit:{1} > /tmp/fzf_k_action)+abort" \
            --bind "ctrl-d:execute-silent(echo delete:{1} > /tmp/fzf_k_action)+abort" \
            --bind "ctrl-l:execute-silent(echo logs:{1} > /tmp/fzf_k_action)+abort"
      )" || break

      local name
      name="$(cat /tmp/fzf_k_name 2>/dev/null || true)"
      local action
      action="$(cat /tmp/fzf_k_action 2>/dev/null || true)"
      : >/tmp/fzf_k_name || true
      : >/tmp/fzf_k_action || true

      if [[ -z "${name}${action}" ]]; then
        # ENTER pressed -> describe
        if [[ -n "$selection" ]]; then name="$selection"; fi
        [[ -n "$name" ]] && do_describe "$kind" "$ns" "$name"
        continue
      fi

      case "$action" in
      yaml:*)
        name="${action#yaml:}"
        open_yaml "$kind" "$ns" "$name"
        ;;
      edit:*)
        name="${action#edit:}"
        do_edit "$kind" "$ns" "$name"
        ;;
      delete:*)
        name="${action#delete:}"
        do_delete "$kind" "$ns" "$name"
        ;;
      logs:*)
        name="${action#logs:}"
        if is_pod_kind "$kind"; then
          do_logs "$ns" "$name"
        else
          read -p "Logs only apply to pods. Press Enter..." _
        fi
        ;;
      *)
        # default: describe
        [[ -n "$selection" ]] && do_describe "$kind" "$ns" "$selection"
        ;;
      esac
    done
  done
}

main_loop
