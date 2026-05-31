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

tomoro_start_spoofdpi() {
    if tomoro_port_in_use "${TOMORO_PROXY_PORT}"; then
        if tomoro_is_running; then
            tomoro_log_warn "Bypass sudah berjalan (PID $(<"${TOMORO_PID_FILE}"))."
            return 0
        fi
        tomoro_log_err "Port ${TOMORO_PROXY_PORT} sudah dipakai. Hentikan proses lain atau set TOMORO_PORT=9090 ./tomoro start"
        exit 1
    fi

    tomoro_ensure_state_dir
    "${TOMORO_SPOOF_BIN}" --listen-addr "127.0.0.1:${TOMORO_PROXY_PORT}" >/dev/null 2>&1 &
    local pid=$!
    sleep 1.2

    if ! kill -0 "$pid" 2>/dev/null; then
        tomoro_log_err "SpoofDPI gagal start. Coba: ./tomoro doctor"
        exit 1
    fi

    echo "$pid" >"${TOMORO_PID_FILE}"
    tomoro_save_port
    tomoro_log_ok "SpoofDPI berjalan (PID ${pid}, port ${TOMORO_PROXY_PORT})"
}

tomoro_stop_spoofdpi() {
    local pid=""
    if [[ -f "${TOMORO_PID_FILE}" ]]; then
        pid="$(<"${TOMORO_PID_FILE}")"
    fi
    if [[ -n "$pid" ]] && kill -0 "$pid" 2>/dev/null; then
        kill "$pid" 2>/dev/null || true
        tomoro_log_ok "SpoofDPI dihentikan (PID ${pid})"
    elif [[ -n "$pid" ]]; then
        tomoro_log_warn "PID tersimpan (${pid}) sudah tidak aktif."
    fi
    rm -f "${TOMORO_PID_FILE}"
}
