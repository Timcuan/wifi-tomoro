#!/bin/bash
# Verifikasi bypass aktif.

tomoro_health_probes() {
    printf '%s\n' \
        "https://dns.google/resolve?name=example.com" \
        "https://api2.cursor.sh" \
        "https://chatgpt.com"
}

tomoro_run_health_check() {
    local via_proxy="${1:-0}"
    local url ok=0 fail=0
    tomoro_read_saved_port

    echo
    tomoro_log_info "Uji koneksi ${via_proxy:+melalui proxy }..."
    echo

    while IFS= read -r url; do
        [[ -z "$url" ]] && continue
        if [[ "$via_proxy" == "1" ]]; then
            if curl -fsSL --max-time 12 -x "http://127.0.0.1:${TOMORO_PROXY_PORT}" "$url" -o /dev/null 2>/dev/null; then
                tomoro_doctor_report "$url" ok "via proxy"
                ok=$((ok + 1))
            else
                tomoro_doctor_report "$url" warn "gagal via proxy"
                fail=$((fail + 1))
            fi
        else
            if curl -fsSL --max-time 8 "$url" -o /dev/null 2>/dev/null; then
                tomoro_doctor_report "$url" ok "langsung"
                ok=$((ok + 1))
            else
                tomoro_doctor_report "$url" warn "terblokir/langsung gagal"
                fail=$((fail + 1))
            fi
        fi
    done < <(tomoro_health_probes)

    echo
    if [[ "$via_proxy" == "1" && $ok -gt 0 ]]; then
        tomoro_log_ok "Bypass merespons (${ok} endpoint OK)"
        return 0
    fi
    if [[ "$via_proxy" != "1" ]]; then
        tomoro_log_info "Jalankan ./tomoro test saat bypass aktif untuk verifikasi penuh."
    else
        tomoro_log_warn "Proxy merespons lemah — coba mode deep atau ./tomoro stop && ./tomoro start --deep"
        return 1
    fi
    return 0
}
