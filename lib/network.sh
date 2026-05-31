#!/bin/bash
# macOS network service ↔ system proxy helpers.

tomoro_get_active_service() {
    local active_intf
    active_intf=$(route get default 2>/dev/null | awk '/interface:/ {print $2}')
    if [[ -z "$active_intf" ]]; then
        echo ""
        return 0
    fi
    networksetup -listnetworkserviceorder 2>/dev/null | \
        awk -F', ' -v dev="$active_intf" '
            $0 ~ "Device: " dev { gsub(/^\([0-9*]+\) /, "", last); print last }
            { last = $0 }
        '
}

tomoro_track_service() {
    local service="$1"
    [[ -z "$service" ]] && return 0
    tomoro_ensure_state_dir
    if [[ -f "${TOMORO_SERVICES_FILE}" ]] && grep -Fxq "$service" "${TOMORO_SERVICES_FILE}" 2>/dev/null; then
        return 0
    fi
    echo "$service" >>"${TOMORO_SERVICES_FILE}"
}

tomoro_enable_proxy_on_service() {
    local service="$1"
    [[ -z "$service" ]] && return 0

    echo -e "  ${TOMORO_GREEN}→${TOMORO_NC} Proxy aktif: ${TOMORO_BOLD}${service}${TOMORO_NC} → 127.0.0.1:${TOMORO_PROXY_PORT}"
    sudo networksetup -setwebproxy "$service" 127.0.0.1 "${TOMORO_PROXY_PORT}"
    sudo networksetup -setsecurewebproxy "$service" 127.0.0.1 "${TOMORO_PROXY_PORT}"
    tomoro_track_service "$service"
}

tomoro_disable_proxy_on_service() {
    local service="$1"
    [[ -z "$service" ]] && return 0

    echo -e "  ${TOMORO_YELLOW}→${TOMORO_NC} Proxy dimatikan: ${TOMORO_BOLD}${service}${TOMORO_NC}"
    sudo networksetup -setwebproxystate "$service" off
    sudo networksetup -setsecurewebproxystate "$service" off
}

tomoro_disable_all_tracked_services() {
    local service
    if [[ -f "${TOMORO_SERVICES_FILE}" ]]; then
        while IFS= read -r service || [[ -n "$service" ]]; do
            tomoro_disable_proxy_on_service "$service"
        done <"${TOMORO_SERVICES_FILE}"
    fi
    local active
    active="$(tomoro_get_active_service)"
    if [[ -n "$active" ]]; then
        tomoro_disable_proxy_on_service "$active"
    fi
}

tomoro_flush_dns() {
    sudo dscacheutil -flushcache 2>/dev/null || true
    sudo killall -HUP mDNSResponder 2>/dev/null || true
}

tomoro_show_proxy_status() {
    local service="$1"
    [[ -z "$service" ]] && return 0
    echo -e "  ${TOMORO_BOLD}${service}${TOMORO_NC}"
    networksetup -getwebproxy "$service" 2>/dev/null | sed 's/^/    /'
    networksetup -getsecurewebproxy "$service" 2>/dev/null | sed 's/^/    /'
}
