#!/bin/bash
# Shared paths, colors, and state for wifi-tomoro.

tomoro_init_paths() {
    if [[ -z "${TOMORO_REPO_DIR:-}" ]]; then
        TOMORO_REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[1]}")/.." && pwd)"
    fi
    TOMORO_BIN_DIR="${TOMORO_REPO_DIR}/bin"
    TOMORO_SPOOF_BIN="${TOMORO_BIN_DIR}/spoofdpi"
    TOMORO_STATE_DIR="${TOMORO_REPO_DIR}/.tomoro"
    TOMORO_PID_FILE="${TOMORO_STATE_DIR}/run.pid"
    TOMORO_SERVICES_FILE="${TOMORO_STATE_DIR}/services"
    TOMORO_PORT_FILE="${TOMORO_STATE_DIR}/port"
    TOMORO_PROXY_PORT="${TOMORO_PORT:-8080}"
}

tomoro_colors() {
    TOMORO_RED='\033[0;31m'
    TOMORO_GREEN='\033[0;32m'
    TOMORO_YELLOW='\033[0;33m'
    TOMORO_BLUE='\033[0;34m'
    TOMORO_MAGENTA='\033[0;35m'
    TOMORO_CYAN='\033[0;36m'
    TOMORO_BOLD='\033[1m'
    TOMORO_NC='\033[0m'
}

tomoro_ensure_state_dir() {
    mkdir -p "${TOMORO_STATE_DIR}"
}

tomoro_log_info() {
    echo -e "${TOMORO_CYAN}[info]${TOMORO_NC} $*"
}

tomoro_log_ok() {
    echo -e "${TOMORO_GREEN}[ok]${TOMORO_NC} $*"
}

tomoro_log_warn() {
    echo -e "${TOMORO_YELLOW}[warn]${TOMORO_NC} $*"
}

tomoro_log_err() {
    echo -e "${TOMORO_RED}[error]${TOMORO_NC} $*" >&2
}

tomoro_require_macos() {
    if [[ "$(uname -s)" != "Darwin" ]]; then
        tomoro_log_err "Tool ini hanya untuk macOS."
        exit 1
    fi
}

tomoro_require_commands() {
    local missing=()
    local cmd
    for cmd in curl tar networksetup route killall; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            missing+=("$cmd")
        fi
    done
    if ((${#missing[@]} > 0)); then
        tomoro_log_err "Perintah tidak ditemukan: ${missing[*]}"
        exit 1
    fi
}

tomoro_read_saved_port() {
    if [[ -f "${TOMORO_PORT_FILE}" ]]; then
        TOMORO_PROXY_PORT="$(<"${TOMORO_PORT_FILE}")"
    fi
}

tomoro_save_port() {
    tomoro_ensure_state_dir
    echo "${TOMORO_PROXY_PORT}" >"${TOMORO_PORT_FILE}"
}

tomoro_is_running() {
    if [[ ! -f "${TOMORO_PID_FILE}" ]]; then
        return 1
    fi
    local pid
    pid="$(<"${TOMORO_PID_FILE}")"
    [[ -n "$pid" ]] && kill -0 "$pid" 2>/dev/null
}

tomoro_port_in_use() {
    local port="$1"
    if command -v lsof >/dev/null 2>&1; then
        lsof -nP -iTCP:"${port}" -sTCP:LISTEN >/dev/null 2>&1
    else
        return 1
    fi
}
