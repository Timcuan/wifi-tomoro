#!/bin/bash
# Restore macOS proxy and DNS after bypass session.

tomoro_cleanup() {
    echo
    tomoro_log_info "Mengembalikan pengaturan sistem ..."
    tomoro_disable_all_tracked_services
    tomoro_stop_spoofdpi
    tomoro_flush_dns
    rm -f "${TOMORO_SERVICES_FILE}"
    tomoro_log_ok "Selesai. Internet kembali normal tanpa proxy lokal."
}

tomoro_reset_state() {
    rm -f "${TOMORO_PID_FILE}" "${TOMORO_SERVICES_FILE}" "${TOMORO_PORT_FILE}"
}
