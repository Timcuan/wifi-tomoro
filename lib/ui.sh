#!/bin/bash
# INGFO TOMORO — banner, animasi, progress

INGFO_TOMORO_NAME="${INGFO_TOMORO_NAME:-INGFO TOMORO}"
TOMORO_VERSION="2.4.1"
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
    [[ ! -t 1 ]] && return 0
    local frames=(
        "Menyiapkan antarmuka"
        "Menyiapkan antarmuka."
        "Menyiapkan antarmuka.."
        "Menyiapkan antarmuka..."
    )
    local spin=('|' '/' '-' '\')
    local i s=0
    tomoro_tui_clear
    tomoro_ui_logo
    for i in "${!frames[@]}"; do
        printf "\r  ${TOMORO_CYAN}%s${TOMORO_NC} %s" "${spin[$((s % 4))]}" "${frames[$i]}"
        s=$((s + 1))
        sleep 0.12
    done
    printf "\r\033[K"
    echo -e "  ${TOMORO_GREEN}[ok]${TOMORO_NC} Siap."
    echo
    sleep 0.2
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
    local filled=$((current * 20 / total))
    local bar="" i
    for ((i = 0; i < 20; i++)); do
        if (( i < filled )); then bar+="#"; else bar+="-"; fi
    done
    echo -e "${TOMORO_MAGENTA}${TOMORO_BOLD}  Langkah ${current}/${total}${TOMORO_NC}  ${label}"
    echo -e "  ${TOMORO_CYAN}[${bar}]${TOMORO_NC}"
}

tomoro_ui_divider() {
    echo -e "  ${TOMORO_DIM}$(tomoro_ui_rule 60)${TOMORO_NC}"
}

tomoro_ui_success_banner() {
    echo
    tomoro_log_ok "Perisai aktif — ${INGFO_TOMORO_NAME}"
    echo
    if declare -f tomoro_show_shield_status >/dev/null 2>&1; then
        tomoro_show_shield_status
        echo
    fi
    echo -e "  ${TOMORO_DIM}Target:${TOMORO_NC} GMGN, crypto, Cursor, ChatGPT"
    echo
    echo -e "  ${TOMORO_YELLOW}${TOMORO_BOLD}Penting${TOMORO_NC}"
    echo -e "    Biarkan terminal ini terbuka"
    echo -e "    Uji: ${TOMORO_BOLD}ingfo test-crypto${TOMORO_NC}"
    echo -e "    Stop: ${TOMORO_BOLD}Ctrl+C${TOMORO_NC} atau ${TOMORO_BOLD}ingfo stop${TOMORO_NC}"
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
    local msg="$1"
    local frames=('|' '/' '-' '\')
    local i=0
    while true; do
        printf "\r  ${TOMORO_CYAN}%s${TOMORO_NC} %s" "${frames[$i]}" "$msg"
        i=$(( (i + 1) % 4 ))
        sleep 0.1
    done
}

tomoro_ui_run_with_spinner() {
    local msg="$1"
    shift
    tomoro_ui_spinner "$msg" &
    local spin_pid=$!
    "$@"
    local exit_code=$?
    kill "$spin_pid" 2>/dev/null || true
    wait "$spin_pid" 2>/dev/null || true
    printf "\r\033[K"
    return "$exit_code"
}

tomoro_usage() {
    tomoro_ui_logo
    echo -e "${TOMORO_BOLD}Perintah utama${TOMORO_NC}"
    echo
    printf "  %-16s %s\n" "ingfo" "Menu ON / OFF + info mekanisme"
    printf "  %-16s %s\n" "ingfo on" "Nyalakan bypass (sama: start)"
    printf "  %-16s %s\n" "ingfo off" "Matikan bypass (sama: stop)"
    echo
    echo -e "${TOMORO_BOLD}Lainnya${TOMORO_NC}"
    printf "  %-16s %s\n" "ingfo status" "Cek ON/OFF"
    printf "  %-16s %s\n" "ingfo test-crypto" "Uji GMGN & crypto"
    printf "  %-16s %s\n" "ingfo doctor" "Diagnosa sistem"
    echo
    echo -e "${TOMORO_DIM}tomoro = alias ingfo · ultra: ingfo on --ultra${TOMORO_NC}"
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
