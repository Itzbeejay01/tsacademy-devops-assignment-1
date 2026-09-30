#!/usr/bin/env bash

# TS Academy DevOps Assignment 1
# Check filesystem usage against a percentage threshold.

set -u

LOG_DIR="logs"
LOG_FILE="$LOG_DIR/toolkit.log"

mkdir -p "$LOG_DIR"

log() {
  printf '[%s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$1" >> "$LOG_FILE"
}

usage() {
  echo "Usage: $0 <threshold> [path]" >&2
  echo "  threshold: integer from 1 to 100" >&2
  echo "  path: filesystem path to inspect (default: /)" >&2
}

if [[ $# -lt 1 || $# -gt 2 ]]; then
  usage
  log "disk-check: invalid number of arguments"
  exit 2
fi

THRESHOLD="$1"
PATH_TO_CHECK="${2:-/}"

if ! [[ "$THRESHOLD" =~ ^[0-9]+$ ]]; then
  echo "Error: threshold must be an integer from 1 to 100." >&2
  log "disk-check: rejected non-numeric threshold '$THRESHOLD'"
  exit 2
fi

if (( THRESHOLD < 1 || THRESHOLD > 100 )); then
  echo "Error: threshold must be between 1 and 100." >&2
  log "disk-check: rejected out-of-range threshold '$THRESHOLD'"
  exit 2
fi

if [[ ! -e "$PATH_TO_CHECK" ]]; then
  echo "Error: path does not exist: $PATH_TO_CHECK" >&2
  log "disk-check: path not found '$PATH_TO_CHECK'"
  exit 2
fi

USAGE_PERCENT=$(df -P "$PATH_TO_CHECK" 2>/dev/null | awk 'NR==2 {gsub(/%/, "", $5); print $5}')

if ! [[ "$USAGE_PERCENT" =~ ^[0-9]+$ ]]; then
  echo "Error: unable to determine disk usage for: $PATH_TO_CHECK" >&2
  log "disk-check: failed to read disk usage for '$PATH_TO_CHECK'"
  exit 1
fi

echo "Path: $PATH_TO_CHECK"
echo "Disk usage: ${USAGE_PERCENT}%"
echo "Threshold: ${THRESHOLD}%"

log "disk-check: path='$PATH_TO_CHECK' usage=${USAGE_PERCENT}% threshold=${THRESHOLD}%"

if (( USAGE_PERCENT >= THRESHOLD )); then
  echo "Status: WARNING - disk usage has reached or exceeded the threshold."
  log "disk-check: threshold reached or exceeded"
  exit 1
fi

echo "Status: OK - disk usage is below the threshold."
log "disk-check: disk usage is below threshold"
exit 0
