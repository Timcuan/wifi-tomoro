#!/bin/bash
# INGFO TOMORO — animasi & feedback terminal

tomoro_anim_is_tty() {
    [[ -t 1 ]]
}

tomoro_anim_alt_on() {
    tomoro_anim_is_tty && printf '\033[?1049h'
}

tomoro_anim_alt_off() {
    tomoro_anim_is_tty && printf '\033[?1049l'
}

tomoro_anim_hide_cursor() {
    tomoro_anim_is_tty && printf '\033[?25l'
}

tomoro_anim_show_cursor() {
    tomoro_anim_is_tty && printf '\033[?25h'
}

tomoro_anim_clear() {
    tomoro_anim_is_tty && printf '\033[2J\033[H'
}

tomoro_anim_sleep() {
    local ms="${1:-80}"
    # macOS bash: sleep accepts decimals
    sleep "$(awk "BEGIN {printf \"%.3f\", $ms/1000}")"
}

tomoro_anim_spinner_start() {
    local msg="$1"
    local -a frames=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏')
    local i=0
    while true; do
        printf "\r  ${TOMORO_CYAN}%s${TOMORO_NC} ${msg}   " "${frames[$i]}"
        i=$(( (i + 1) % ${#frames[@]} ))
        tomoro_anim_sleep 70
    done
}

tomoro_anim_spinner_stop() {
    local pid="$1"
    local ok="${2:-1}"
    kill "$pid" 2>/dev/null || true
    wait "$pid" 2>/dev/null || true
    if [[ "$ok" == "1" ]]; then
        printf "\r\033[K  ${TOMORO_GREEN}[ok]${TOMORO_NC} %s\n" "${3:-Selesai}"
    else
        printf "\r\033[K  ${TOMORO_RED}[x]${TOMORO_NC} %s\n" "${3:-Gagal}"
    fi
}

tomoro_anim_run() {
    local msg="$1"
    shift
    tomoro_anim_spinner_start "$msg" &
    local sp=$!
    "$@"
    local rc=$?
    if [[ $rc -eq 0 ]]; then
        tomoro_anim_spinner_stop "$sp" 1 "$msg"
    else
        tomoro_anim_spinner_stop "$sp" 0 "$msg"
    fi
    return "$rc"
}

tomoro_anim_bar_line() {
    local pct="$1"
    local width="${2:-24}"
    local filled=$(( pct * width / 100 ))
    local bar="" i
    for ((i = 0; i < width; i++)); do
        if (( i < filled )); then
            bar+='█'
        else
            bar+='░'
        fi
    done
    printf '%s' "$bar"
}

tomoro_anim_progress_tick() {
    local cur="$1" total="$2" label="$3" pct="$4"
    local bar
    bar="$(tomoro_anim_bar_line "$pct")"
    printf "\r  ${TOMORO_MAGENTA}${TOMORO_BOLD}%s${TOMORO_NC} ${TOMORO_DIM}(%s/%s)${TOMORO_NC} ${label}\n" \
        "$bar" "$cur" "$total"
    printf "  ${TOMORO_DIM}%3s%%${TOMORO_NC}\r" "$pct"
}

tomoro_anim_progress_animate() {
    local cur="$1" total="$2" label="$3"
    local target=$((cur * 100 / total))
    local p start=0
    echo -e "  ${TOMORO_MAGENTA}${TOMORO_BOLD}[${cur}/${total}]${TOMORO_NC} ${label}"
    for p in $(seq 5 5 "$target"); do
        printf "\r  ${TOMORO_CYAN}$(tomoro_anim_bar_line "$p" 28)${TOMORO_NC} ${TOMORO_DIM}%3d%%${TOMORO_NC}" "$p"
        tomoro_anim_sleep 30
    done
    printf "\r  ${TOMORO_GREEN}$(tomoro_anim_bar_line "$target" 28)${TOMORO_NC} ${TOMORO_DIM}ok${TOMORO_NC}   \n"
}

tomoro_anim_progress_done() {
    :
}

tomoro_anim_brand_reveal() {
    [[ ! -t 1 ]] && { tomoro_ui_brand; echo; return 0; }
    tomoro_anim_clear
    echo
    echo -ne "  ${TOMORO_MAGENTA}${TOMORO_BOLD}INGFO${TOMORO_NC}"
    tomoro_anim_sleep 120
    echo -e " ${TOMORO_CYAN}${TOMORO_BOLD}TOMORO${TOMORO_NC}"
    tomoro_anim_sleep 80
    echo -e "  ${TOMORO_DIM}${TOMORO_TAGLINE}${TOMORO_NC}"
    tomoro_anim_sleep 60
    echo -e "  ${TOMORO_DIM}v${TOMORO_VERSION}${TOMORO_NC}"
    echo -e "  ${TOMORO_DIM}$(tomoro_ui_rule 44)${TOMORO_NC}"
    echo
}

tomoro_anim_intro() {
    [[ ! -t 1 ]] && return 0
    tomoro_anim_brand_reveal
    tomoro_anim_spinner_start "Memuat menu" &
    local sp=$!
    tomoro_anim_sleep 450
    tomoro_anim_spinner_stop "$sp" 1 "Siap"
    echo
}

tomoro_anim_flash() {
    local text="$1" color="${2:-${TOMORO_GREEN}}"
    printf "\r  ${color}${TOMORO_BOLD}%s${TOMORO_NC}\n" "$text"
    tomoro_anim_sleep 180
}

tomoro_anim_pulse_status() {
    local on="$1"
    if [[ "$on" == "1" ]]; then
        local frames=(
            "${TOMORO_GREEN}${TOMORO_BOLD}● ON${TOMORO_NC}  bypass aktif"
            "${TOMORO_GREEN}◉ ON${TOMORO_NC}  bypass aktif"
        )
        local i
        for i in 0 1 0; do
            printf "\r  %b   " "${frames[$i]}"
            tomoro_anim_sleep 200
        done
        printf "\r\033[K"
    fi
}
