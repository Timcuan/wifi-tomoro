#!/bin/bash
# Pasang shortcut `ingfo` ke PATH (macOS)

INGFO_PATH_MARKER="# INGFO TOMORO — PATH"
INGFO_PATH_LINE='export PATH="${HOME}/.local/bin:${PATH}"'

ingfo_install_ensure_bin_dir() {
    mkdir -p "${INGFO_BIN}"
    ln -sf "${INGFO_DIR}/ingfo" "${INGFO_BIN}/ingfo"
    ln -sf "${INGFO_DIR}/tomoro" "${INGFO_BIN}/tomoro"
    chmod +x "${INGFO_DIR}/ingfo" "${INGFO_DIR}/tomoro" 2>/dev/null || true
}

ingfo_install_ensure_path_in_shell() {
    local rc
    for rc in "${HOME}/.zshrc" "${HOME}/.bash_profile" "${HOME}/.bashrc"; do
        [[ -f "$rc" ]] || continue
        if grep -qF "${INGFO_PATH_MARKER}" "$rc" 2>/dev/null; then
            continue
        fi
        printf '\n%s\n%s\n' "${INGFO_PATH_MARKER}" "${INGFO_PATH_LINE}" >>"$rc"
    done
}

ingfo_install_activate_path_now() {
    export PATH="${INGFO_BIN}:${PATH}"
}

ingfo_install_verify_shortcut() {
    if command -v ingfo >/dev/null 2>&1; then
        return 0
    fi
    return 1
}
