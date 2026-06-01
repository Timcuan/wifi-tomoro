#!/bin/bash
# INGFO TOMORO — banner, animasi, progress

INGFO_TOMORO_NAME="${INGFO_TOMORO_NAME:-INGFO TOMORO}"
TOMORO_VERSION="2.5.0"
TOMORO_TAGLINE="macOS WiFi bypass · DPI · GMGN & crypto"

tomoro_ui_rule() {
    local width="${1:-48}"
    printf '%*s\n' "$width" '' | tr ' ' '-'
}

tomoro_ui_brand() {
    tomoro_ui_dim_init
    echo
    echo -e "  ${TOMORO_MAGENTA}${TOMORO_BOLD}INGFO${TOMORO_NC} ${TOMORO_CYAN}${TOMORO_BOLD}TOMORO${TOMORO_NC}"
    echo -e "  ${TOMORO_DIM}${TOMORO_TAGLINE}${TOMORO_NC}"
    echo -e "  ${TOMORO_DIM}v${TOMORO_VERSION}${TOMORO_NC}"
    echo -e "  ${TOMORO_DIM}$(tomoro_ui_rule 44)${TOMORO_NC}"
}

tomoro_ui_logo() {
    tomoro_ui_brand
    echo
}

tomoro_ui_intro_animation() {
    if declare -f tomoro_anim_intro >/dev/null 2>&1; then
        tomoro_anim_intro
    else
        tomoro_ui_logo
    fi
}

tomoro_ui_dim_init() {
    if [[ -t 1 ]]; then
        TOMORO_DIM='\033[2m'
    else
        TOMORO_DIM=''
    fi
}

tomoro_print_header() {
    tomoro_ui_brand
    echo
    echo -e "  ${TOMORO_DIM}Folder${TOMORO_NC}  ${TOMORO_BLUE}${TOMORO_REPO_DIR}${TOMORO_NC}"
    echo -e "  ${TOMORO_DIM}Port${TOMORO_NC}    ${TOMORO_BOLD}${TOMORO_PROXY_PORT}${TOMORO_NC}"
    echo
}

tomoro_ui_step() {
    local current="$1"
    local total="$2"
    local label="$3"
    if declare -f tomoro_anim_progress_animate >/dev/null 2>&1 && [[ -t 1 ]]; then
        tomoro_anim_progress_animate "$current" "$total" "$label"
    else
        echo -e "${TOMORO_MAGENTA}${TOMORO_BOLD}  [${current}/${total}]${TOMORO_NC} ${label}"
    fi
}

tomoro_ui_step_done() {
    :
}

tomoro_ui_divider() {
    echo -e "  ${TOMORO_DIM}$(tomoro_ui_rule 60)${TOMORO_NC}"
}

tomoro_ui_success_banner() {
    echo
    if declare -f tomoro_anim_flash >/dev/null 2>&1; then
        tomoro_anim_flash "Perisai ON — ${INGFO_TOMORO_NAME}" "${TOMORO_GREEN}"
    else
        tomoro_log_ok "Perisai aktif — ${INGFO_TOMORO_NAME}"
    fi
    echo
    if declare -f tomoro_show_shield_status >/dev/null 2>&1; then
        tomoro_show_shield_status
        echo
    fi
    echo -e "  ${TOMORO_DIM}Target:${TOMORO_NC} GMGN, crypto, Cursor, ChatGPT"
    echo
    echo -e "  ${TOMORO_YELLOW}${TOMORO_BOLD}Penting${TOMORO_NC}"
    echo -e "    Terminal ini tetap terbuka"
    echo -e "    OFF dari terminal lain: ${TOMORO_BOLD}ingfo off${TOMORO_NC}"
    tomoro_ui_divider
    echo
}

tomoro_ui_status_card() {
    local title="$1"
    local state="$2"
    local detail="$3"
    local badge color
    case "$state" in
        on)   badge="[aktif]";   color="${TOMORO_GREEN}" ;;
        off)  badge="[mati]";    color="${TOMORO_DIM}" ;;
        warn) badge="[peringatan]"; color="${TOMORO_YELLOW}" ;;
        *)    badge="[?]"; color="${TOMORO_NC}" ;;
    esac
    echo -e "  ${color}${TOMORO_BOLD}${badge}${TOMORO_NC}  ${TOMORO_BOLD}${title}${TOMORO_NC}"
    [[ -n "$detail" ]] && echo -e "  ${TOMORO_DIM}${detail}${TOMORO_NC}"
    echo
}

tomoro_ui_spinner() {
    tomoro_anim_spinner_start "$1" &
    echo $!
}

tomoro_ui_run_with_spinner() {
    local msg="$1"
    shift
    if declare -f tomoro_anim_run >/dev/null 2>&1; then
        tomoro_anim_run "$msg" "$@"
    else
        "$@"
    fi
}

tomoro_usage() {
    tomoro_ui_logo
    echo -e "${TOMORO_BOLD}Perintah utama${TOMORO_NC}"
    echo
    printf "  %-16s %s\n" "ingfo" "Menu ON / OFF"
    printf "  %-16s %s\n" "ingfo on" "Nyalakan bypass"
    printf "  %-16s %s\n" "ingfo off" "Matikan bypass"
    echo
    echo -e "${TOMORO_BOLD}Lainnya${TOMORO_NC}"
    printf "  %-16s %s\n" "ingfo status" "Cek ON/OFF"
    printf "  %-16s %s\n" "ingfo test-crypto" "Uji GMGN & crypto"
    printf "  %-16s %s\n" "ingfo doctor" "Diagnosa sistem"
    echo
}

tomoro_doctor_report() {
    local label="$1"
    local state="$2"
    local note="${3:-}"
    local tag color
    case "$state" in
        ok)   tag="ok"; color="${TOMORO_GREEN}" ;;
        warn) tag="!";  color="${TOMORO_YELLOW}" ;;
        err)  tag="x";  color="${TOMORO_RED}" ;;
        *)    tag="-";  color="${TOMORO_NC}" ;;
    esac
    printf "  ${color}[%s]${TOMORO_NC} %-22s" "$tag" "$label"
    [[ -n "$note" ]] && printf " ${TOMORO_DIM}%s${TOMORO_NC}" "$note"
    echo
}
