#!/usr/bin/env bash

# TS Academy DevOps Assignment 1
# Display Linux system information gathered at runtime.

set -u

LOG_DIR="logs"
LOG_FILE="$LOG_DIR/toolkit.log"

mkdir -p "$LOG_DIR"

log() {
  printf '[%s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$1" >> "$LOG_FILE"
}

get_os() {
  if [[ -r /etc/os-release ]]; then
    . /etc/os-release
    printf '%s\n' "${PRETTY_NAME:-${NAME:-Linux}}"
  else
    uname -s
  fi
}

get_cpu_info() {
  if command -v lscpu >/dev/null 2>&1; then
    lscpu | awk -F: '/Model name/ {gsub(/^[ \t]+/, "", $2); print $2; exit}'
  elif [[ -r /proc/cpuinfo ]]; then
    awk -F: '/model name/ {gsub(/^[ \t]+/, "", $2); print $2; exit}' /proc/cpuinfo
  else
    printf 'Unavailable\n'
  fi
}

get_memory_info() {
  if command -v free >/dev/null 2>&1; then
    free -h | awk '/^Mem:/ {printf "Total: %s, Used: %s, Available: %s\n", $2, $3, $7}'
  elif [[ -r /proc/meminfo ]]; then
    awk '/MemTotal/ {printf "Total: %s %s\n", $2, $3; exit}' /proc/meminfo
  else
    printf 'Unavailable\n'
  fi
}

log "system-info: collecting system information"

printf '%s\n' "========== System Information =========="
printf 'Hostname: %s\n' "$(hostname)"
printf 'Current user: %s\n' "$(id -un)"
printf 'Date/Time: %s\n' "$(date '+%Y-%m-%d %H:%M:%S %Z')"
printf 'Operating system: %s\n' "$(get_os)"
printf 'Kernel version: %s\n' "$(uname -r)"
printf 'Uptime: %s\n' "$(uptime -p 2>/dev/null || uptime)"
printf 'CPU information: %s\n' "$(get_cpu_info)"
printf 'Memory information: %s\n' "$(get_memory_info)"
printf 'Current working directory: %s\n' "$(pwd)"
printf '%s\n' "========================================"

log "system-info: collection completed successfully"
exit 0
