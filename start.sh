#!/bin/bash

# ==============================================================================
# TOMORO-BYPASS: Portable & Smart macOS DPI Bypass Utility
# ==============================================================================
# Self-contained, portable script for bypassing ISP internet censorship (DPI).
# Dynamically tracks network changes and restores proxy states automatically.
# ==============================================================================

# Curated harmonious color palette
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Directory paths
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN_DIR="${REPO_DIR}/bin"
SPOOF_BIN="${BIN_DIR}/spoofdpi"
PROXY_PORT=8080

# Keep track of services where we enabled the proxy
declare -a PROXY_ENABLED_SERVICES

# Helper: Get currently active network service name
get_active_service() {
    local active_intf
    active_intf=$(route get default 2>/dev/null | grep interface | awk '{print $2}')
    if [ -z "$active_intf" ]; then
        echo ""
        return
    fi
    # Map interface (en0) to human-readable network service name (e.g., Wi-Fi)
    networksetup -listnetworkserviceorder | \
        awk -F', ' -v dev="$active_intf" '/Device: '"$active_intf"'/ {print last} {last=$0}' | \
        sed -E 's/^\([0-9*]+\) //'
}

# Helper: Enable proxy on a service
enable_proxy_on_service() {
    local service="$1"
    if [ -z "$service" ]; then return; fi
    
    echo -e "  [${GREEN}*${NC}] Setting proxy on: ${BOLD}${service}${NC}..."
    # Set HTTP and HTTPS proxies
    sudo networksetup -setwebproxy "$service" 127.0.0.1 $PROXY_PORT
    sudo networksetup -setsecurewebproxy "$service" 127.0.0.1 $PROXY_PORT
    
    # Track this service so we can clean it up later
    if [[ ! " ${PROXY_ENABLED_SERVICES[*]} " =~ " ${service} " ]]; then
        PROXY_ENABLED_SERVICES+=("$service")
    fi
}

# Helper: Disable proxy on a service
disable_proxy_on_service() {
    local service="$1"
    if [ -z "$service" ]; then return; fi
    
    echo -e "  [${YELLOW}*${NC}] Restoring proxy on: ${BOLD}${service}${NC}..."
    sudo networksetup -setwebproxystate "$service" off
    sudo networksetup -setsecurewebproxystate "$service" off
}

# Cleanup function (Graceful exit on Ctrl+C)
cleanup() {
    echo -e "\n\n${YELLOW}${BOLD}🧹 RESTORING SYSTEM SETTINGS...${NC}"
    
    # Disable proxy on all services where we enabled it
    for service in "${PROXY_ENABLED_SERVICES[@]}"; do
        disable_proxy_on_service "$service"
    done
    
    # Double check currently active service
    local current_service
    current_service=$(get_active_service)
    if [ -n "$current_service" ]; then
        disable_proxy_on_service "$current_service"
    fi
    
    # Terminate spoofdpi child process
    if [ -n "$SPOOF_PID" ]; then
        echo -e "  [${RED}*${NC}] Stopping SpoofDPI daemon..."
        kill "$SPOOF_PID" 2>/dev/null || true
    fi
    
    # Flush macOS DNS Cache
    sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder 2>/dev/null || true
    
    echo -e "${GREEN}${BOLD}✔ System restored successfully. Goodbye!${NC}"
    exit 0
}

# Trap signals for graceful exit
trap cleanup SIGINT SIGTERM EXIT

# Print beautiful header
echo -e "${CYAN}${BOLD}======================================================================${NC}"
echo -e "${CYAN}${BOLD}            ☕ TOMORO BYPASS: PORTABLE CENSORSHIP BYPASS              ${NC}"
echo -e "${CYAN}${BOLD}======================================================================${NC}"
echo -e "   Status   : ${GREEN}Active Network & DPI Tracking${NC}"
echo -e "   Directory: ${BLUE}${REPO_DIR}${NC}"
echo -e "${CYAN}======================================================================${NC}\n"

# Step 1: Detect architecture & ensure SpoofDPI is installed locally
if [ ! -f "$SPOOF_BIN" ]; then
    echo -e "${YELLOW}[1/3] SpoofDPI binary not found locally. Preparing download...${NC}"
    mkdir -p "$BIN_DIR"
    
    # Detect macOS architecture
    ARCH=$(uname -m)
    case "$ARCH" in
        x86_64)  SPOOF_ARCH="x86_64" ;;
        arm64)   SPOOF_ARCH="arm64" ;;
        *)
            echo -e "${RED}❌ Unsupported architecture: ${ARCH}${NC}"
            exit 1
            ;;
    esac
    
    echo -e "  OS   : macOS (Darwin)"
    echo -e "  Arch : ${BOLD}${ARCH}${NC} (${SPOOF_ARCH})"
    
    # Fetch latest release tag and version
    LATEST_TAG=$(curl -s https://api.github.com/repos/xvzc/spoofdpi/releases/latest | grep tag_name | cut -d '"' -f 4)
    if [ -z "$LATEST_TAG" ]; then
        LATEST_TAG="v1.5.3"
    fi
    VERSION=${LATEST_TAG#v}
    
    DOWNLOAD_URL="https://github.com/xvzc/spoofdpi/releases/download/${LATEST_TAG}/spoofdpi_${VERSION}_darwin_${SPOOF_ARCH}.tar.gz"
    echo -e "  URL  : ${BLUE}${DOWNLOAD_URL}${NC}"
    
    # Download tarball directly into bin folder
    echo -e "  Downloading..."
    curl -L -s -o "${BIN_DIR}/spoofdpi.tar.gz" "$DOWNLOAD_URL"
    
    # Extract tarball
    echo -e "  Extracting..."
    tar -xzf "${BIN_DIR}/spoofdpi.tar.gz" -C "$BIN_DIR"
    
    # Remove tarball and leftover release assets
    rm "${BIN_DIR}/spoofdpi.tar.gz" 2>/dev/null || true
    rm "${BIN_DIR}/README.md" 2>/dev/null || true
    rm "${BIN_DIR}/LICENSE" 2>/dev/null || true
    rm "${BIN_DIR}/CHANGELOG.md" 2>/dev/null || true
    
    # Ensure binary is executable
    chmod +x "$SPOOF_BIN"
    echo -e "${GREEN}✔ SpoofDPI successfully installed inside local repository directory.${NC}\n"
else
    echo -e "${GREEN}✔ SpoofDPI binary already present locally in repo (${SPOOF_BIN})${NC}\n"
fi

# Step 2: Request sudo permission early (so it doesn't prompt in the background)
echo -e "${YELLOW}[2/3] Verifying administrator (sudo) privileges...${NC}"
echo -e "We need sudo privileges to modify your macOS System Proxy Settings."
# Trigger sudo authentication cache
sudo -v

# Step 3: Start SpoofDPI locally
echo -e "\n${YELLOW}[3/3] Launching SpoofDPI Proxy daemon...${NC}"
# Run SpoofDPI in background
"$SPOOF_BIN" --listen-addr "127.0.0.1:$PROXY_PORT" > /dev/null 2>&1 &
SPOOF_PID=$!

# Give it a second to bind to port
sleep 1.5
if ! kill -0 "$SPOOF_PID" 2>/dev/null; then
    echo -e "${RED}❌ Error: Failed to start SpoofDPI. Port $PROXY_PORT might be in use.${NC}"
    exit 1
fi
echo -e "  [${GREEN}✔${NC}] SpoofDPI running on PID: ${BOLD}${SPOOF_PID}${NC} (Port: ${BOLD}${PROXY_PORT}${NC})"

# Step 4: Run dynamic network tracking loop
echo -e "\n${GREEN}${BOLD}🚀 BYPASS INJECTED SUCCESSFULLY!${NC}"
echo -e "You can now access blocked sites (Cursor, Reddit, ChatGPT, etc.) without a VPN."
echo -e "${MAGENTA}${BOLD}💡 IMPORTANT: Keep this terminal open! Press [Ctrl+C] to stop and clean up.${NC}"
echo -e "${CYAN}----------------------------------------------------------------------${NC}"

# Track active network service
PREV_SERVICE=""

while true; do
    ACTIVE_SERVICE=$(get_active_service)
    
    if [ -z "$ACTIVE_SERVICE" ]; then
        # No default network route
        if [ -n "$PREV_SERVICE" ]; then
            echo -e "\n${RED}⚠️ Network connection lost!${NC}"
            disable_proxy_on_service "$PREV_SERVICE"
            PREV_SERVICE=""
        fi
    elif [ "$ACTIVE_SERVICE" != "$PREV_SERVICE" ]; then
        # Active service changed (switched networks!)
        echo -e "\n${CYAN}🔄 Network change detected!${NC}"
        
        # Clean up old service proxy to avoid leaving the user's internet broken
        if [ -n "$PREV_SERVICE" ]; then
            disable_proxy_on_service "$PREV_SERVICE"
        fi
        
        # Configure the new service
        enable_proxy_on_service "$ACTIVE_SERVICE"
        PREV_SERVICE="$ACTIVE_SERVICE"
        
        echo -e "${GREEN}👉 Active bypass switched to: ${BOLD}${ACTIVE_SERVICE}${NC}"
        # Flush DNS cache just in case
        sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder 2>/dev/null || true
    fi
    
    # Verify SpoofDPI is still alive
    if ! kill -0 "$SPOOF_PID" 2>/dev/null; then
        echo -e "\n${RED}❌ SpoofDPI process died unexpectedly! Exiting...${NC}"
        exit 1
    fi
    
    # Cache sudo credentials so they don't expire mid-execution
    sudo -n true 2>/dev/null
    
    sleep 3
done
