#!/bin/bash
# INGFO TOMORO — instalasi + shortcut terminal `ingfo`

set -euo pipefail

INGFO_REPO="${INGFO_REPO:-https://github.com/Timcuan/wifi-tomoro.git}"
INGFO_DIR="${INGFO_DIR:-${HOME}/ingfo-tomoro}"
INGFO_BIN="${INGFO_BIN:-${HOME}/.local/bin}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/install-path.sh
source "${SCRIPT_DIR}/lib/install-path.sh"

CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
MAGENTA='\033[0;35m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

ingfo_spin() {
    local msg="$1"
    local frames=('|' '/' '-' '\')
    local i=0
    while true; do
        printf "\r  ${CYAN}%s${NC} %s" "${frames[$i]}" "$msg"
        i=$(( (i + 1) % 4 ))
        sleep 0.09
    done
}

ingfo_step_ok() {
    printf "\r\033[K  ${GREEN}[ok]${NC} %s\n" "$1"
}

ingfo_step_fail() {
    printf "\r\033[K  ${RED}[x]${NC} %s\n" "$1" >&2
}

ingfo_banner() {
    echo
    echo -e "  ${MAGENTA}${BOLD}INGFO${NC} ${CYAN}${BOLD}TOMORO${NC}"
    echo -e "  ${DIM}Install · shortcut terminal: ingfo${NC}"
    echo -e "  ${DIM}----------------------------------------${NC}"
    echo
}

main() {
    ingfo_banner

    if [[ "$(uname -s)" != "Darwin" ]]; then
        ingfo_step_fail "Hanya untuk macOS."
        exit 1
    fi

    for cmd in git curl; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            ingfo_step_fail "Perlu: $cmd"
            exit 1
        fi
    done

    if [[ -d "${INGFO_DIR}/.git" ]]; then
        ingfo_spin "Update repo ..."
        git -C "${INGFO_DIR}" pull --ff-only >/dev/null 2>&1 &
        wait $! || true
        ingfo_step_ok "Repo: ${INGFO_DIR}"
    else
        ingfo_spin "Clone GitHub ..."
        git clone --depth 1 "${INGFO_REPO}" "${INGFO_DIR}"
        ingfo_step_ok "Clone: ${INGFO_DIR}"
    fi

    chmod +x "${INGFO_DIR}/ingfo" "${INGFO_DIR}/tomoro" "${INGFO_DIR}/start.sh" "${INGFO_DIR}/install.sh" 2>/dev/null || true
    ingfo_step_ok "Binary siap"

    ingfo_install_ensure_bin_dir
    ingfo_step_ok "Shortcut: ${INGFO_BIN}/ingfo"

    ingfo_install_ensure_path_in_shell
    ingfo_step_ok "PATH di ~/.zshrc / ~/.bash_profile"

    ingfo_install_activate_path_now

    if ingfo_install_verify_shortcut; then
        ingfo_step_ok "Perintah global: ingfo"
    else
        ingfo_step_fail "ingfo belum di PATH — buka terminal baru atau: source ~/.zshrc"
    fi

    echo
    echo -e "  ${GREEN}${BOLD}Selesai${NC}"
    echo
    echo -e "  ${BOLD}Pakai dari terminal mana saja:${NC}"
    echo -e "    ${CYAN}${BOLD}ingfo${NC}       ${DIM}menu ON / OFF${NC}"
    echo -e "    ${CYAN}${BOLD}ingfo on${NC}     ${DIM}nyalakan bypass${NC}"
    echo -e "    ${CYAN}${BOLD}ingfo off${NC}    ${DIM}matikan bypass${NC}"
    echo
    echo -e "  ${DIM}Terminal baru otomatis kenal ingfo. Sesi ini sudah aktif jika [ok] di atas.${NC}"
    echo
}

main "$@"
