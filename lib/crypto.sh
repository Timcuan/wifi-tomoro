#!/bin/bash
# Domain & uji koneksi crypto (GMGN, DEX, CEX, RPC).

# Domain yang sering kena DPI / DNS filter di WiFi ID — dapat rules SpoofDPI agresif
tomoro_crypto_rule_domains() {
    cat <<'EOF'
gmgn.ai
*.gmgn.ai
*.gmgn.cc
dexscreener.com
*.dexscreener.com
coingecko.com
*.coingecko.com
coinmarketcap.com
*.coinmarketcap.com
binance.com
*.binance.com
okx.com
*.okx.com
bybit.com
*.bybit.com
gate.io
*.gate.io
mexc.com
*.mexc.com
kucoin.com
*.kucoin.com
jupiter.ag
*.jupiter.ag
pump.fun
*.pump.fun
raydium.io
*.raydium.io
birdeye.so
*.birdeye.so
uniswap.org
*.uniswap.org
metamask.io
*.metamask.io
walletconnect.org
*.walletconnect.org
helius-rpc.com
*.helius-rpc.com
alchemy.com
*.alchemy.com
infura.io
*.infura.io
solana.com
*.solana.com
EOF
}

tomoro_crypto_domains_toml_array() {
    local first=1 line
    while IFS= read -r line; do
        [[ -z "$line" ]] && continue
        if [[ $first -eq 1 ]]; then
            printf '"%s"' "$line"
            first=0
        else
            printf ', "%s"' "$line"
        fi
    done < <(tomoro_crypto_rule_domains)
}

tomoro_append_crypto_rules_to_config() {
    local https_rule
    if [[ "${TOMORO_ULTRA}" == "1" ]]; then
        https_rule='{ disorder = true, split-mode = "chunk", chunk-size = 1, fake-count = 5 }'
    else
        https_rule='{ disorder = true, split-mode = "chunk", chunk-size = 35 }'
    fi

    cat >>"${TOMORO_SPOOF_CONFIG}" <<EOF

# Crypto / GMGN — bypass DPI prioritas tinggi (auto)
[[rules]]
name = "crypto-gmgn-dex-cex"
match = { domains = [$(tomoro_crypto_domains_toml_array)] }
https = ${https_rule}
EOF
}

# URL uji: fokus TLS terbuka via proxy (403 Cloudflare = OK, bukan blok ISP)
tomoro_crypto_health_probes() {
    printf '%s\n' \
        "https://gmgn.ai" \
        "https://dexscreener.com" \
        "https://www.coingecko.com" \
        "https://app.uniswap.org" \
        "https://jupiter.ag" \
        "https://pump.fun" \
        "https://www.binance.com" \
        "https://api.mainnet-beta.solana.com"
}

tomoro_curl_http_code() {
    local url="$1" via_proxy="$2"
    local code
    if [[ "$via_proxy" == "1" ]]; then
        tomoro_read_saved_port
        code=$(curl -sS -o /dev/null -w "%{http_code}" --max-time 15 \
            -x "http://127.0.0.1:${TOMORO_PROXY_PORT}" "$url" 2>/dev/null) || code="000"
    else
        code=$(curl -sS -o /dev/null -w "%{http_code}" --max-time 10 "$url" 2>/dev/null) || code="000"
    fi
    echo "$code"
}

tomoro_crypto_probe_label() {
    local code="$1"
    case "$code" in
        000) echo "tidak terjangkau (DPI/RST?)" ;;
        403) echo "TLS OK · CF/WAF (buka di browser)" ;;
        503) echo "TLS OK · challenge/rate-limit" ;;
        200|301|302|307|308) echo "HTTP ${code} OK" ;;
        *)   echo "TLS OK · HTTP ${code}" ;;
    esac
}

tomoro_crypto_probe_state() {
    local code="$1"
    [[ "$code" == "000" ]] && echo "err" && return
    [[ "$code" == "403" || "$code" == "503" ]] && echo "warn" && return
    echo "ok"
}

tomoro_run_crypto_health_check() {
    local via_proxy="${1:-0}"
    local url code state label ok=0 warn=0 fail=0

    echo
    if [[ "$via_proxy" == "1" ]]; then
        tomoro_log_info "Uji crypto via proxy (GMGN, DEX, CEX, RPC) ..."
    else
        tomoro_log_info "Uji crypto langsung (baseline — bandingkan saat bypass aktif) ..."
    fi
    echo

    while IFS= read -r url; do
        [[ -z "$url" ]] && continue
        code="$(tomoro_curl_http_code "$url" "$via_proxy")"
        state="$(tomoro_crypto_probe_state "$code")"
        label="$(tomoro_crypto_probe_label "$code")"
        host="$(echo "$url" | sed -E 's|https?://([^/]+).*|\1|; s|^www\.||')"
        tomoro_doctor_report "${host:0:26}" "$state" "$label"
        case "$state" in
            ok)   ok=$((ok + 1)) ;;
            warn) warn=$((warn + 1)) ;;
            err)  fail=$((fail + 1)) ;;
        esac
    done < <(tomoro_crypto_health_probes)

    echo
    tomoro_ui_divider
    echo
    if [[ "$via_proxy" == "1" ]]; then
        if [[ $fail -eq 0 ]]; then
            tomoro_log_ok "Crypto terjangkau via bypass (${ok} OK, ${warn} CF/challenge — normal di curl)"
            tomoro_log_info "GMGN/dexscreener: buka di browser; 403 curl ≠ blok WiFi jika halaman load."
            return 0
        fi
        tomoro_log_warn "${fail} situs masih tidak terjangkau — coba: ./tomoro start --ultra"
        return 1
    fi
    tomoro_log_info "Jalankan ./tomoro start lalu ./tomoro test-crypto untuk bandingkan."
    return 0
}
