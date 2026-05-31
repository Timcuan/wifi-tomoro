#!/bin/bash
# Mode bypass: standard | deep (default deep)

tomoro_init_config() {
    TOMORO_MODE="${TOMORO_MODE:-deep}"
    TOMORO_DNS_DOH_URL="${TOMORO_DNS_DOH_URL:-https://dns.google/dns-query}"
    TOMORO_SOCKS_ENABLE="${TOMORO_SOCKS_ENABLE:-1}"
    TOMORO_SOCKS_PORT="${TOMORO_SOCKS_PORT:-1080}"
    # fake-count > 0 butuh pcap/root di macOS — aktifkan hanya dengan TOMORO_ULTRA=1
    TOMORO_ULTRA="${TOMORO_ULTRA:-0}"
    TOMORO_SPOOF_CONFIG="${TOMORO_STATE_DIR}/spoofdpi.toml"
    TOMORO_LOG_FILE="${TOMORO_STATE_DIR}/spoofdpi.log"
    TOMORO_MODE_FILE="${TOMORO_STATE_DIR}/mode"
    TOMORO_DNS_BACKUP_DIR="${TOMORO_STATE_DIR}/dns-backup"
    TOMORO_IPV6_OFF_FILE="${TOMORO_STATE_DIR}/ipv6-off"
    TOMORO_SOCKS_PID_FILE="${TOMORO_STATE_DIR}/socks.pid"
}

tomoro_parse_start_flags() {
    local arg
    for arg in "$@"; do
        case "$arg" in
            --deep)   TOMORO_MODE="deep" ;;
            --standard|--lite) TOMORO_MODE="standard" ;;
            --ultra)  TOMORO_MODE="deep"; TOMORO_ULTRA="1" ;;
        esac
    done
}

tomoro_mode_label() {
    case "${TOMORO_MODE}" in
        deep)
            if [[ "${TOMORO_ULTRA}" == "1" ]]; then
                echo "deep+ultra (fake TLS + pcap)"
            else
                echo "deep (DPI disorder + DoH + DNS + multi-IF)"
            fi
            ;;
        standard) echo "standard (DoH + SNI split)" ;;
        *)        echo "${TOMORO_MODE}" ;;
    esac
}

tomoro_write_spoofdpi_config() {
    tomoro_ensure_state_dir
    if [[ "${TOMORO_MODE}" == "deep" ]]; then
        if [[ "${TOMORO_ULTRA}" == "1" ]]; then
            cat >"${TOMORO_SPOOF_CONFIG}" <<EOF
# Wifi Tomoro — profil deep+ultra (perlu akses paket/raw)
[dns]
mode = "https"
https-url = "${TOMORO_DNS_DOH_URL}"
cache = true

[https]
fake-count = 7
disorder = true
split-mode = "chunk"
chunk-size = 1
EOF
        else
            cat >"${TOMORO_SPOOF_CONFIG}" <<EOF
# Wifi Tomoro — profil deep (tanpa root pada daemon)
[dns]
mode = "https"
https-url = "${TOMORO_DNS_DOH_URL}"
cache = true

[https]
disorder = true
split-mode = "chunk"
chunk-size = 35
EOF
        fi
    else
        cat >"${TOMORO_SPOOF_CONFIG}" <<EOF
# Wifi Tomoro — profil standard
[dns]
mode = "https"
https-url = "${TOMORO_DNS_DOH_URL}"
cache = true

[https]
split-mode = "sni"
disorder = false
EOF
    fi
    echo "${TOMORO_MODE}" >"${TOMORO_MODE_FILE}"
    [[ "${TOMORO_ULTRA}" == "1" ]] && echo "ultra" >>"${TOMORO_MODE_FILE}"
    if declare -f tomoro_append_crypto_rules_to_config >/dev/null 2>&1; then
        tomoro_append_crypto_rules_to_config
    fi
}

tomoro_spoofdpi_http_args() {
    local args=(
        --config "${TOMORO_SPOOF_CONFIG}"
        --listen-addr "127.0.0.1:${TOMORO_PROXY_PORT}"
        --app-mode http
        --no-tui
        --log-level warn
        --dns-mode https
        --dns-https-url "${TOMORO_DNS_DOH_URL}"
        --dns-cache
    )
    if [[ "${TOMORO_MODE}" == "deep" ]]; then
        args+=(
            --https-disorder
            --https-split-mode chunk
            --https-chunk-size 35
        )
        if [[ "${TOMORO_ULTRA}" == "1" ]]; then
            args+=(
                --https-fake-count 7
                --https-chunk-size 1
            )
        fi
    else
        args+=(--https-split-mode sni)
    fi
    printf '%s\n' "${args[@]}"
}

tomoro_spoofdpi_socks_args() {
    printf '%s\n' \
        --config "${TOMORO_SPOOF_CONFIG}" \
        --listen-addr "127.0.0.1:${TOMORO_SOCKS_PORT}" \
        --app-mode socks5 \
        --no-tui \
        --log-level warn \
        --dns-mode https \
        --dns-https-url "${TOMORO_DNS_DOH_URL}" \
        --dns-cache \
        --https-disorder \
        --https-split-mode chunk \
        --https-chunk-size 35
}

tomoro_spoofdpi_needs_root() {
    [[ "${TOMORO_ULTRA}" == "1" ]]
}
