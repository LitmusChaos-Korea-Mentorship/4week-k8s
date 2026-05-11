#!/usr/bin/env bash
set -u

CLUSTER_NAME="${CLUSTER_NAME:-k8s-lab}"
CONTEXT_NAME="kind-${CLUSTER_NAME}"

log() {
  printf '[cleanup] %s\n' "$1"
}

command_exists() {
  command -v "$1" >/dev/null 2>&1
}

stop_port_forward() {
  if ! command_exists pgrep || ! command_exists pkill; then
    return 0
  fi

  if pgrep -f "kubectl.*port-forward" >/dev/null 2>&1; then
    log "stopping kubectl port-forward processes"
    pkill -f "kubectl.*port-forward" || true
  fi
}

delete_namespace_if_available() {
  local namespace="$1"

  if ! command_exists kubectl; then
    return 0
  fi

  if kubectl config get-contexts "$CONTEXT_NAME" >/dev/null 2>&1; then
    kubectl config use-context "$CONTEXT_NAME" >/dev/null 2>&1 || true
  fi

  if kubectl get namespace "$namespace" >/dev/null 2>&1; then
    log "deleting namespace ${namespace}"
    kubectl delete namespace "$namespace" --wait=false >/dev/null 2>&1 || true
  fi
}

delete_kind_cluster() {
  if ! command_exists kind; then
    log "kind is not installed; skip cluster deletion"
    return 0
  fi

  if kind get clusters 2>/dev/null | grep -qx "$CLUSTER_NAME"; then
    log "deleting kind cluster ${CLUSTER_NAME}"
    kind delete cluster --name "$CLUSTER_NAME"
  else
    log "kind cluster ${CLUSTER_NAME} not found"
  fi
}

main() {
  log "starting cleanup for ${CLUSTER_NAME}"

  stop_port_forward
  delete_namespace_if_available "chaos-lab"
  delete_namespace_if_available "k8s-lab"
  delete_kind_cluster

  log "done"
}

main "$@"
