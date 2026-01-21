#!/bin/bash

# ParameterX Installation Script
# Author: Ilham Rizvi
# GitHub: https://github.com/alhamrizvi-cloud/ParameterX

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}"
cat << "EOF"
 ____                                _            __  __
|  _ \ __ _ _ __ __ _ _ __ ___   ___| |_ ___ _ __\ \/ /
| |_) / _' | '__/ _' | '_ ' _ \ / _ \ __/ _ \ '__|\  / 
|  __/ (_| | | | (_| | | | | | |  __/ ||  __/ |   /  \ 
|_|   \__,_|_|  \__,_|_| |_| |_|\___|\__\___|_|  /_/\_\
                                                        
          Installation Script v1.0.0
EOF
echo -e "${NC}"

# Check if Go is installed
if ! command -v go &> /dev/null; then
    echo -e "${RED}[!] Go is not installed. Please install Go 1.19 or higher.${NC}"
    echo -e "${YELLOW}[*] Visit: https://golang.org/doc/install${NC}"
    exit 1
fi

GO_VERSION=$(go version | awk '{print $3}' | sed 's/go//')
echo -e "${GREEN}[✓] Go ${GO_VERSION} detected${NC}"

# Check Go version (requires 1.19+)
REQUIRED_VERSION="1.19"
if [ "$(printf '%s\n' "$REQUIRED_VERSION" "$GO_VERSION" | sort -V | head -n1)" != "$REQUIRED_VERSION" ]; then
    echo -e "${RED}[!] Go version 1.19 or higher is required${NC}"
    exit 1
fi

# Create temporary directory
TMP_DIR=$(mktemp -d)
echo -e "${BLUE}[*] Using temporary directory: ${TMP_DIR}${NC}"

# Clone repository
echo -e "${BLUE}[*] Cloning ParameterX repository...${NC}"
cd "$TMP_DIR"
git clone https://github.com/alhamrizvi-cloud/ParameterX.git
cd ParameterX

# Build binary
echo -e "${BLUE}[*] Building ParameterX...${NC}"
go build -o parameterx main.go

# Check if build was successful
if [ ! -f "parameterx" ]; then
    echo -e "${RED}[!] Build failed${NC}"
    exit 1
fi

echo -e "${GREEN}[✓] Build successful${NC}"

# Install binary
INSTALL_DIR="/usr/local/bin"
if [ -w "$INSTALL_DIR" ]; then
    echo -e "${BLUE}[*] Installing to ${INSTALL_DIR}...${NC}"
    mv parameterx "$INSTALL_DIR/"
    chmod +x "$INSTALL_DIR/parameterx"
else
    echo -e "${YELLOW}[*] Requesting sudo access to install to ${INSTALL_DIR}...${NC}"
    sudo mv parameterx "$INSTALL_DIR/"
    sudo chmod +x "$INSTALL_DIR/parameterx"
fi

# Cleanup
echo -e "${BLUE}[*] Cleaning up...${NC}"
cd ~
rm -rf "$TMP_DIR"

# Verify installation
if command -v parameterx &> /dev/null; then
    echo -e "${GREEN}"
    echo "╔════════════════════════════════════════════╗"
    echo "║   ✓ ParameterX installed successfully!    ║"
    echo "╚════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo -e "${BLUE}[*] Version:${NC}"
    parameterx -h | head -n 7
    echo ""
    echo -e "${GREEN}[*] Try: parameterx -d example.com -o output.txt${NC}"
    echo -e "${YELLOW}[*] For more info: parameterx -h${NC}"
else
    echo -e "${RED}[!] Installation failed${NC}"
    exit 1
fi

exit 0