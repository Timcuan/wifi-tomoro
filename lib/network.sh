#!/bin/bash
# macOS network service ↔ system proxy, DNS, hardening.

tomoro_list_enabled_services() {
    local line service
    while IFS= read -r line; do
        [[ "$line" == \** ]] && continue
        [[ -z "$line" ]] && continue
        service="${line#\* }"
        [[ -n "$service" ]] && printf '%s\n' "$service"
    done < <(networksetup -listallnetworkservices 2>/dev/null | tail -n +2)
}

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

tomoro_service_slug() {
    echo -n "$1" | shasum 2>/dev/null | awk '{print $1}' || echo "$1" | tr -cd '[:alnum:]' | head -c 32
}

tomoro_backup_dns_for_service() {
    local service="$1"
    [[ -z "$service" ]] && return 0
    tomoro_ensure_state_dir
    mkdir -p "${TOMORO_DNS_BACKUP_DIR}"
    local slug backup_file current
    slug="$(tomoro_service_slug "$service")"
    backup_file="${TOMORO_DNS_BACKUP_DIR}/${slug}"
    [[ -f "$backup_file" ]] && return 0

    current="$(networksetup -getdnsservers "$service" 2>/dev/null || true)"
    {
        printf 'SERVICE:%s\n' "$service"
        if [[ "$current" == *"aren't any"* ]] || [[ "$current" == *"Empty"* ]]; then
            echo "DHCP"
        else
            printf '%s\n' "$current"
        fi
    } >"$backup_file"
}

tomoro_restore_dns_for_service() {
    local service="$1"
    [[ -z "$service" ]] && return 0
    local slug backup_file
    slug="$(tomoro_service_slug "$service")"
    backup_file="${TOMORO_DNS_BACKUP_DIR}/${slug}"
    [[ ! -f "$backup_file" ]] && return 0

    echo -e "  ${TOMORO_YELLOW}→${TOMORO_NC} DNS dipulihkan: ${TOMORO_BOLD}${service}${TOMORO_NC}"
    if grep -qx "DHCP" "$backup_file" 2>/dev/null; then
        sudo networksetup -setdnsservers "$service" Empty
    else
        local -a servers=()
        while IFS= read -r line; do
            [[ "$line" == SERVICE:* ]] && continue
            [[ -z "$line" ]] && continue
            servers+=("$line")
        done <"$backup_file"
        if ((${#servers[@]} > 0)); then
            sudo networksetup -setdnsservers "$service" "${servers[@]}"
        else
            sudo networksetup -setdnsservers "$service" Empty
        fi
    fi
    rm -f "$backup_file"
}

tomoro_harden_dns_for_service() {
    local service="$1"
    [[ -z "$service" ]] && return 0
    tomoro_backup_dns_for_service "$service"
    echo -e "  ${TOMORO_GREEN}→${TOMORO_NC} DNS aman (DoH-ready): ${TOMORO_BOLD}${service}${TOMORO_NC}"
    sudo networksetup -setdnsservers "$service" 1.1.1.1 8.8.8.8
}

tomoro_disable_ipv6_for_service() {
    local service="$1"
    [[ -z "$service" ]] && return 0
    [[ "${TOMORO_MODE:-deep}" != "deep" ]] && return 0
    grep -Fxq "$service" "${TOMORO_IPV6_OFF_FILE}" 2>/dev/null && return 0
    echo -e "  ${TOMORO_GREEN}→${TOMORO_NC} IPv6 off (cegah leak): ${TOMORO_BOLD}${service}${TOMORO_NC}"
    sudo networksetup -setv6off "$service"
    echo "$service" >>"${TOMORO_IPV6_OFF_FILE}"
}

tomoro_restore_ipv6_for_service() {
    local service="$1"
    [[ -z "$service" ]] && return 0
    [[ ! -f "${TOMORO_IPV6_OFF_FILE}" ]] && return 0
    grep -Fxq "$service" "${TOMORO_IPV6_OFF_FILE}" 2>/dev/null || return 0
    echo -e "  ${TOMORO_YELLOW}→${TOMORO_NC} IPv6 dipulihkan: ${TOMORO_BOLD}${service}${TOMORO_NC}"
    sudo networksetup -setv6automatic "$service" 2>/dev/null || true
    grep -Fxv "$service" "${TOMORO_IPV6_OFF_FILE}" >"${TOMORO_IPV6_OFF_FILE}.tmp" 2>/dev/null || true
    mv "${TOMORO_IPV6_OFF_FILE}.tmp" "${TOMORO_IPV6_OFF_FILE}" 2>/dev/null || rm -f "${TOMORO_IPV6_OFF_FILE}"
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

tomoro_set_proxy_bypass_local() {
    local service="$1"
    [[ -z "$service" ]] && return 0
    sudo networksetup -setproxybypassdomains "$service" \
        localhost 127.0.0.1 "*.local" "*.localhost" 169.254.0.0 10.0.0.0/8 192.168.0.0/16
}

tomoro_enable_proxy_on_service() {
    local service="$1"
    [[ -z "$service" ]] && return 0

    echo -e "  ${TOMORO_GREEN}→${TOMORO_NC} Proxy HTTP/S: ${TOMORO_BOLD}${service}${TOMORO_NC} → 127.0.0.1:${TOMORO_PROXY_PORT}"
    sudo networksetup -setwebproxy "$service" 127.0.0.1 "${TOMORO_PROXY_PORT}"
    sudo networksetup -setsecurewebproxy "$service" 127.0.0.1 "${TOMORO_PROXY_PORT}"
    sudo networksetup -setwebproxystate "$service" on
    sudo networksetup -setsecurewebproxystate "$service" on

    if [[ "${TOMORO_SOCKS_ENABLE:-0}" == "1" ]] && [[ -f "${TOMORO_SOCKS_PID_FILE}" ]]; then
        echo -e "  ${TOMORO_GREEN}→${TOMORO_NC} Proxy SOCKS: ${TOMORO_BOLD}${service}${TOMORO_NC} → 127.0.0.1:${TOMORO_SOCKS_PORT}"
        sudo networksetup -setsocksfirewallproxy "$service" 127.0.0.1 "${TOMORO_SOCKS_PORT}"
        sudo networksetup -setsocksfirewallproxystate "$service" on
    fi

    tomoro_set_proxy_bypass_local "$service"
    tomoro_track_service "$service"
}

tomoro_harden_service() {
    local service="$1"
    [[ -z "$service" ]] && return 0
    tomoro_enable_proxy_on_service "$service"
    if [[ "${TOMORO_MODE:-deep}" == "deep" ]]; then
        tomoro_harden_dns_for_service "$service"
        tomoro_disable_ipv6_for_service "$service"
    fi
}

tomoro_disable_proxy_on_service() {
    local service="$1"
    [[ -z "$service" ]] && return 0

    echo -e "  ${TOMORO_YELLOW}→${TOMORO_NC} Proxy dimatikan: ${TOMORO_BOLD}${service}${TOMORO_NC}"
    sudo networksetup -setwebproxystate "$service" off
    sudo networksetup -setsecurewebproxystate "$service" off
    sudo networksetup -setsocksfirewallproxystate "$service" off 2>/dev/null || true
}

tomoro_restore_service_fully() {
    local service="$1"
    [[ -z "$service" ]] && return 0
    tomoro_disable_proxy_on_service "$service"
    tomoro_restore_dns_for_service "$service"
    tomoro_restore_ipv6_for_service "$service"
}

tomoro_apply_deep_to_all_services() {
    local service
    tomoro_log_info "Menerapkan hardening ke semua interface jaringan ..."
    while IFS= read -r service; do
        tomoro_harden_service "$service"
    done < <(tomoro_list_enabled_services)
}

tomoro_disable_all_tracked_services() {
    local service
    if [[ -f "${TOMORO_SERVICES_FILE}" ]]; then
        while IFS= read -r service || [[ -n "$service" ]]; do
            tomoro_restore_service_fully "$service"
        done <"${TOMORO_SERVICES_FILE}"
    fi
    local active
    active="$(tomoro_get_active_service)"
    if [[ -n "$active" ]]; then
        tomoro_restore_service_fully "$active"
    fi
    if [[ -d "${TOMORO_DNS_BACKUP_DIR}" ]]; then
        local backup svc
        for backup in "${TOMORO_DNS_BACKUP_DIR}"/*; do
            [[ -f "$backup" ]] || continue
            svc="$(grep '^SERVICE:' "$backup" 2>/dev/null | cut -d: -f2-)"
            [[ -n "$svc" ]] && tomoro_restore_dns_for_service "$svc"
        done
    fi
    if [[ -f "${TOMORO_IPV6_OFF_FILE}" ]]; then
        while IFS= read -r service || [[ -n "$service" ]]; do
            tomoro_restore_ipv6_for_service "$service"
        done <"${TOMORO_IPV6_OFF_FILE}"
        rm -f "${TOMORO_IPV6_OFF_FILE}"
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
    networksetup -getsocksfirewallproxy "$service" 2>/dev/null | sed 's/^/    /'
    networksetup -getdnsservers "$service" 2>/dev/null | sed 's/^/    DNS: /'
}

tomoro_show_shield_status() {
    local mode="standard" ultra=""
    [[ -f "${TOMORO_MODE_FILE}" ]] && mode="$(head -1 "${TOMORO_MODE_FILE}")"
    grep -qx "ultra" "${TOMORO_MODE_FILE}" 2>/dev/null && ultra=" + ultra"
    TOMORO_MODE="$mode"
    echo -e "  ${TOMORO_BOLD}Mode${TOMORO_NC}     : $(tomoro_mode_label)${ultra}"
    echo -e "  ${TOMORO_BOLD}Lapisan${TOMORO_NC}  : DoH · TLS disorder · fragmentasi SNI/chunk"
    if [[ "$mode" == "deep" ]]; then
        echo -e "             DNS publik · IPv6 off · semua interface · SOCKS"
        [[ -n "$ultra" ]] && echo -e "             ${TOMORO_YELLOW}fake TLS packets (daemon sudo)${TOMORO_NC}"
    fi
}
