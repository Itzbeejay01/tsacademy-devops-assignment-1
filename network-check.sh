#!/usr/bin/env bash

# TS Academy DevOps Assignment 1
# Resolve a host, perform connectivity checks, show interfaces, and optionally test a TCP port.

set -u

LOG_DIR="logs"
LOG_FILE="$LOG_DIR/toolkit.log"

mkdir -p "$LOG_DIR"

log() {
  printf '[%s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$1" >> "$LOG_FILE"
}

usage() {
  echo "Usage: $0 <hostname-or-ip> [port]" >&2
}

if [[ $# -lt 1 || $# -gt 2 ]]; then
  usage
  log "network-check: invalid number of arguments"
  exit 2
fi

HOST="$1"
PORT="${2:-}"

if [[ -z "$HOST" || ! "$HOST" =~ ^[A-Za-z0-9._:-]+$ ]]; then
  echo "Error: invalid hostname or IP address." >&2
  log "network-check: rejected invalid host '$HOST'"
  exit 2
fi

if [[ -n "$PORT" ]]; then
  if ! [[ "$PORT" =~ ^[0-9]+$ ]]; then
    echo "Error: port must be an integer from 1 to 65535." >&2
    log "network-check: rejected non-numeric port '$PORT'"
    exit 2
  fi

  if (( PORT < 1 || PORT > 65535 )); then
    echo "Error: port must be between 1 and 65535." >&2
    log "network-check: rejected out-of-range port '$PORT'"
    exit 2
  fi
fi

log "network-check: checking host='$HOST'${PORT:+ port='$PORT'}"

RESOLVED=""

if command -v getent >/dev/null 2>&1; then
  RESOLVED=$(getent ahostsv4 "$HOST" 2>/dev/null | awk 'NR==1 {print $1}')
  if [[ -z "$RESOLVED" ]]; then
    RESOLVED=$(getent hosts "$HOST" 2>/dev/null | awk 'NR==1 {print $1}')
  fi
elif command -v host >/dev/null 2>&1; then
  RESOLVED=$(host "$HOST" 2>/dev/null | awk '/has address/ {print $4; exit}')
fi

if [[ -z "$RESOLVED" ]]; then
  echo "Error: unable to resolve host: $HOST" >&2
  log "network-check: failed to resolve '$HOST'"
  exit 1
fi

echo "Host: $HOST"
echo "Resolved address: $RESOLVED"

RESULT=0

echo
echo "Connectivity check:"
if command -v ping >/dev/null 2>&1; then
  if ping -c 1 -W 2 "$HOST" >/dev/null 2>&1; then
    echo "Ping: reachable"
    log "network-check: ping to '$HOST' succeeded"
  else
    echo "Ping: no reply (ICMP may be blocked)"
    log "network-check: ping to '$HOST' did not receive a reply"
    RESULT=1
  fi
else
  echo "Ping: command not available"
  log "network-check: ping command unavailable"
fi

echo
echo "Network interface information:"
if command -v ip >/dev/null 2>&1; then
  ip -brief address
elif command -v ifconfig >/dev/null 2>&1; then
  ifconfig
elif command -v hostname >/dev/null 2>&1; then
  echo "Local addresses: $(hostname -I 2>/dev/null || echo 'unavailable')"
else
  echo "Interface information unavailable"
fi

if [[ -n "$PORT" ]]; then
  echo
  echo "TCP port check: $HOST:$PORT"

  if command -v nc >/dev/null 2>&1; then
    if nc -z -w 3 "$HOST" "$PORT" >/dev/null 2>&1; then
      echo "TCP port $PORT: reachable"
      log "network-check: TCP '$HOST:$PORT' succeeded"
      RESULT=0
    else
      echo "TCP port $PORT: unreachable or closed"
      log "network-check: TCP '$HOST:$PORT' failed"
      RESULT=1
    fi
  elif command -v timeout >/dev/null 2>&1; then
    if timeout 3 bash -c "exec 3<>/dev/tcp/$HOST/$PORT" >/dev/null 2>&1; then
      echo "TCP port $PORT: reachable"
      log "network-check: TCP '$HOST:$PORT' succeeded using /dev/tcp"
      RESULT=0
    else
      echo "TCP port $PORT: unreachable or closed"
      log "network-check: TCP '$HOST:$PORT' failed using /dev/tcp"
      RESULT=1
    fi
  else
    echo "TCP check unavailable: install netcat or timeout."
    log "network-check: no supported TCP checking utility"
    RESULT=1
  fi
fi

exit "$RESULT"
