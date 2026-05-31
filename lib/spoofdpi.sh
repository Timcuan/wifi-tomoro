#!/bin/bash
# Local SpoofDPI install and process management.

tomoro_spoof_arch() {
    case "$(uname -m)" in
        x86_64) echo "x86_64" ;;
        arm64)  echo "arm64" ;;
        *)
            tomoro_log_err "Arsitektur tidak didukung: $(uname -m)"
            exit 1
            ;;
    esac
}

tomoro_fetch_latest_tag() {
    local tag
    tag=$(curl -fsSL --max-time 15 \
        https://api.github.com/repos/xvzc/spoofdpi/releases/latest 2>/dev/null \
        | sed -n 's/.*"tag_name": "\([^"]*\)".*/\1/p' | head -1)
    if [[ -z "$tag" ]]; then
        tag="v1.5.3"
        tomoro_log_warn "Gagal cek rilis terbaru; memakai fallback ${tag}"
    fi
    echo "$tag"
}

tomoro_install_spoofdpi() {
    if [[ -x "${TOMORO_SPOOF_BIN}" ]]; then
        tomoro_log_ok "SpoofDPI sudah ada: ${TOMORO_SPOOF_BIN}"
        return 0
    fi

    tomoro_log_info "Mengunduh SpoofDPI ke folder bin/ ..."
    mkdir -p "${TOMORO_BIN_DIR}"

    local arch tag version url tarball
    arch="$(tomoro_spoof_arch)"
    tag="$(tomoro_fetch_latest_tag)"
    version="${tag#v}"
    url="https://github.com/xvzc/spoofdpi/releases/download/${tag}/spoofdpi_${version}_darwin_${arch}.tar.gz"
    tarball="${TOMORO_BIN_DIR}/spoofdpi.tar.gz"

    echo -e "  ${TOMORO_DIM}Arch${TOMORO_NC} : ${TOMORO_BOLD}${arch}${TOMORO_NC}"
    echo -e "  ${TOMORO_DIM}Rilis${TOMORO_NC}: ${tag}"
    echo

    _tomoro_download_tarball() {
        curl -fL --max-time 120 -o "$tarball" "$url"
    }
    if declare -f tomoro_ui_run_with_spinner >/dev/null 2>&1; then
        tomoro_ui_run_with_spinner "Mengunduh dari GitHub ..." _tomoro_download_tarball
    else
        _tomoro_download_tarball
    fi
    if [[ ! -s "$tarball" ]]; then
        tomoro_log_err "Unduhan gagal. Periksa koneksi internet."
        rm -f "$tarball"
        exit 1
    fi

    if ! tar -xzf "$tarball" -C "${TOMORO_BIN_DIR}"; then
        tomoro_log_err "Ekstrak arsip gagal."
        rm -f "$tarball"
        exit 1
    fi

    rm -f "$tarball" \
        "${TOMORO_BIN_DIR}/README.md" \
        "${TOMORO_BIN_DIR}/LICENSE" \
        "${TOMORO_BIN_DIR}/CHANGELOG.md"

    if [[ ! -f "${TOMORO_SPOOF_BIN}" ]]; then
        tomoro_log_err "Binary spoofdpi tidak ditemukan setelah ekstrak."
        exit 1
    fi

    chmod +x "${TOMORO_SPOOF_BIN}"
    tomoro_log_ok "SpoofDPI terpasang di ${TOMORO_SPOOF_BIN}"
}

tomoro_start_spoofdpi_process() {
    local -a args=()
    while IFS= read -r line; do args+=("$line"); done < <(tomoro_spoofdpi_http_args)
    if tomoro_spoofdpi_needs_root; then
        tomoro_log_warn "Mode ultra: SpoofDPI HTTP dijalankan dengan sudo (fake TLS) ..."
        sudo -E "${TOMORO_SPOOF_BIN}" "${args[@]}" >>"${TOMORO_LOG_FILE}" 2>&1 &
    else
        "${TOMORO_SPOOF_BIN}" "${args[@]}" >>"${TOMORO_LOG_FILE}" 2>&1 &
    fi
    echo $!
}

tomoro_start_spoofdpi_socks() {
    local -a args=()
    while IFS= read -r line; do args+=("$line"); done < <(tomoro_spoofdpi_socks_args)
    "${TOMORO_SPOOF_BIN}" "${args[@]}" >>"${TOMORO_LOG_FILE}" 2>&1 &
    echo $!
}

tomoro_start_spoofdpi() {
    if tomoro_port_in_use "${TOMORO_PROXY_PORT}"; then
        if tomoro_is_running; then
            tomoro_log_warn "Bypass sudah berjalan (PID $(<"${TOMORO_PID_FILE}"))."
            return 0
        fi
        tomoro_log_err "Port ${TOMORO_PROXY_PORT} sudah dipakai. Set TOMORO_PORT=9090 ./tomoro start"
        exit 1
    fi

    tomoro_ensure_state_dir
    tomoro_write_spoofdpi_config
    : >"${TOMORO_LOG_FILE}"

    tomoro_log_info "Mode: $(tomoro_mode_label)"
    tomoro_log_info "Profil SpoofDPI: ${TOMORO_SPOOF_CONFIG}"

    local pid socks_pid=""
    pid="$(tomoro_start_spoofdpi_process)"
    sleep 1.2

    if ! kill -0 "$pid" 2>/dev/null; then
        tomoro_log_err "SpoofDPI HTTP gagal start. Log: ${TOMORO_LOG_FILE}"
        tail -5 "${TOMORO_LOG_FILE}" 2>/dev/null || true
        exit 1
    fi

    if [[ "${TOMORO_MODE}" == "deep" && "${TOMORO_SOCKS_ENABLE}" == "1" ]]; then
        if tomoro_port_in_use "${TOMORO_SOCKS_PORT}"; then
            tomoro_log_warn "Port SOCKS ${TOMORO_SOCKS_PORT} dipakai — lewati SOCKS."
            TOMORO_SOCKS_ENABLE=0
        else
            socks_pid="$(tomoro_start_spoofdpi_socks)"
            sleep 0.8
            if kill -0 "$socks_pid" 2>/dev/null; then
                echo "$socks_pid" >"${TOMORO_SOCKS_PID_FILE}"
                tomoro_log_ok "SOCKS5 aktif (PID ${socks_pid}, port ${TOMORO_SOCKS_PORT})"
            else
                tomoro_log_warn "SOCKS5 gagal — lanjut HTTP-only. Log: ${TOMORO_LOG_FILE}"
                TOMORO_SOCKS_ENABLE=0
                rm -f "${TOMORO_SOCKS_PID_FILE}"
            fi
        fi
    fi

    echo "$pid" >"${TOMORO_PID_FILE}"
    tomoro_save_port
    tomoro_log_ok "SpoofDPI HTTP aktif (PID ${pid}, port ${TOMORO_PROXY_PORT})"
}

tomoro_stop_spoofdpi() {
    local pid socks_pid=""
    if [[ -f "${TOMORO_PID_FILE}" ]]; then
        pid="$(<"${TOMORO_PID_FILE}")"
    fi
    if [[ -f "${TOMORO_SOCKS_PID_FILE}" ]]; then
        socks_pid="$(<"${TOMORO_SOCKS_PID_FILE}")"
    fi
    if [[ -n "$socks_pid" ]] && kill -0 "$socks_pid" 2>/dev/null; then
        kill "$socks_pid" 2>/dev/null || true
        tomoro_log_ok "SOCKS5 dihentikan (PID ${socks_pid})"
    fi
    if [[ -n "$pid" ]] && kill -0 "$pid" 2>/dev/null; then
        kill "$pid" 2>/dev/null || true
        tomoro_log_ok "SpoofDPI dihentikan (PID ${pid})"
    elif [[ -n "$pid" ]]; then
        tomoro_log_warn "PID tersimpan (${pid}) sudah tidak aktif."
    fi
    rm -f "${TOMORO_PID_FILE}" "${TOMORO_SOCKS_PID_FILE}"
}

tomoro_is_socks_running() {
    [[ -f "${TOMORO_SOCKS_PID_FILE}" ]] || return 1
    local pid
    pid="$(<"${TOMORO_SOCKS_PID_FILE}")"
    [[ -n "$pid" ]] && kill -0 "$pid" 2>/dev/null
}
