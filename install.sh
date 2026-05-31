#!/bin/bash
# INGFO TOMORO — instalasi satu perintah (macOS)

set -euo pipefail

INGFO_REPO="${INGFO_REPO:-https://github.com/Timcuan/wifi-tomoro.git}"
INGFO_DIR="${INGFO_DIR:-${HOME}/ingfo-tomoro}"
INGFO_BIN="${INGFO_BIN:-${HOME}/.local/bin}"

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
    local frames=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧')
    local i=0
    while true; do
        printf "\r  ${CYAN}%s${NC} %s" "${frames[$i]}" "$msg"
        i=$(( (i + 1) % ${#frames[@]} ))
        sleep 0.09
    done
}

ingfo_step_ok() {
    printf "\r\033[K  ${GREEN}✓${NC} %s\n" "$1"
}

ingfo_step_fail() {
    printf "\r\033[K  ${RED}✗${NC} %s\n" "$1" >&2
}

ingfo_banner() {
    echo
    echo -e "  ${MAGENTA}${BOLD}INGFO${NC} ${CYAN}${BOLD}TOMORO${NC}"
    echo -e "  ${DIM}Installer · macOS WiFi bypass${NC}"
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
        ingfo_spin "Update repositori ..."
        git -C "${INGFO_DIR}" pull --ff-only >/dev/null 2>&1 &
        local pid=$!
        wait "$pid" || true
        ingfo_step_ok "Repo di ${INGFO_DIR}"
    else
        ingfo_spin "Clone dari GitHub ..."
        git clone --depth 1 "${INGFO_REPO}" "${INGFO_DIR}" >/dev/null 2>&1 &
        pid=$!
        wait "$pid"
        ingfo_step_ok "Clone selesai → ${INGFO_DIR}"
    fi

    ingfo_spin "Set permission ..."
    chmod +x "${INGFO_DIR}/ingfo" "${INGFO_DIR}/tomoro" "${INGFO_DIR}/start.sh" "${INGFO_DIR}/install.sh" 2>/dev/null || true
    sleep 0.3
    ingfo_step_ok "ingfo, tomoro executable"

    mkdir -p "${INGFO_BIN}"
    ln -sf "${INGFO_DIR}/ingfo" "${INGFO_BIN}/ingfo"
    ln -sf "${INGFO_DIR}/tomoro" "${INGFO_BIN}/tomoro"
    ingfo_step_ok "Symlink → ${INGFO_BIN}/ingfo"

    case ":${PATH}:" in
        *":${INGFO_BIN}:"*) ;;
        *)
            echo
            echo -e "  ${YELLOW}Tambahkan ke PATH${NC} (zsh):"
            echo -e "  ${DIM}echo 'export PATH=\"\${HOME}/.local/bin:\$PATH\"' >> ~/.zshrc && source ~/.zshrc${NC}"
            ;;
    esac

    echo
    echo -e "  ${GREEN}${BOLD}Instalasi selesai!${NC}"
    echo
    echo -e "  ${BOLD}Mulai:${NC}"
    echo -e "    cd ${INGFO_DIR} && ./ingfo"
    echo -e "    ${DIM}atau: ingfo${NC} ${DIM}(jika PATH sudah di-set)${NC}"
    echo
    echo -e "  ${DIM}Menu ↑↓ · Enter · GMGN/crypto/Cursor unblock${NC}"
    echo
}

main "$@"
