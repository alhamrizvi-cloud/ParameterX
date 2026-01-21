#!/bin/bash

# ParameterX Bug Bounty Workflow Script
# Author: Ilham Rizvi
# Description: Automated workflow for parameter discovery and vulnerability hunting

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# Banner
echo -e "${BLUE}"
cat << "EOF"
╔═══════════════════════════════════════════════════════╗
║        ParameterX Bug Bounty Workflow                ║
║        Automated Recon & Vuln Discovery              ║
╚═══════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

# Check if target is provided
if [ -z "$1" ]; then
    echo -e "${RED}[!] Usage: $0 <target.com>${NC}"
    echo -e "${YELLOW}[*] Example: $0 example.com${NC}"
    exit 1
fi

TARGET=$1
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
WORK_DIR="recon_${TARGET}_${TIMESTAMP}"

# Create working directory
echo -e "${BLUE}[*] Creating working directory: ${WORK_DIR}${NC}"
mkdir -p "${WORK_DIR}"/{subdomains,parameters,vulnerabilities,logs}
cd "${WORK_DIR}"

LOG_FILE="logs/workflow.log"
exec > >(tee -a "${LOG_FILE}") 2>&1

echo -e "${GREEN}[✓] Workspace created${NC}"
echo -e "${BLUE}[*] Target: ${TARGET}${NC}"
echo -e "${BLUE}[*] Started: $(date)${NC}"
echo ""

# Function to check if command exists
check_tool() {
    if ! command -v "$1" &> /dev/null; then
        echo -e "${RED}[!] $1 is not installed${NC}"
        echo -e "${YELLOW}[*] Please install $1 to continue${NC}"
        return 1
    fi
    return 0
}

# Phase 1: Subdomain Enumeration
echo -e "${PURPLE}╔════════════════════════════════════════╗${NC}"
echo -e "${PURPLE}║  Phase 1: Subdomain Enumeration       ║${NC}"
echo -e "${PURPLE}╚════════════════════════════════════════╝${NC}"
echo ""

if check_tool "subfinder"; then
    echo -e "${BLUE}[*] Running subfinder...${NC}"
    subfinder -d "${TARGET}" -silent -o subdomains/subfinder.txt
    echo -e "${GREEN}[✓] Subfinder complete: $(wc -l < subdomains/subfinder.txt) subdomains${NC}"
fi

if check_tool "assetfinder"; then
    echo -e "${BLUE}[*] Running assetfinder...${NC}"
    assetfinder --subs-only "${TARGET}" > subdomains/assetfinder.txt
    echo -e "${GREEN}[✓] Assetfinder complete: $(wc -l < subdomains/assetfinder.txt) subdomains${NC}"
fi

# Combine and deduplicate subdomains
echo -e "${BLUE}[*] Combining subdomain lists...${NC}"
cat subdomains/*.txt 2>/dev/null | sort -u > subdomains/all_subdomains.txt
TOTAL_SUBS=$(wc -l < subdomains/all_subdomains.txt)
echo -e "${GREEN}[✓] Total unique subdomains: ${TOTAL_SUBS}${NC}"
echo ""

# Phase 2: Live Host Detection
echo -e "${PURPLE}╔════════════════════════════════════════╗${NC}"
echo -e "${PURPLE}║  Phase 2: Live Host Detection         ║${NC}"
echo -e "${PURPLE}╚════════════════════════════════════════╝${NC}"
echo ""

if check_tool "httpx"; then
    echo -e "${BLUE}[*] Running httpx...${NC}"
    cat subdomains/all_subdomains.txt | httpx -silent -mc 200,301,302,403 -o subdomains/live_hosts.txt
    LIVE_HOSTS=$(wc -l < subdomains/live_hosts.txt)
    echo -e "${GREEN}[✓] Live hosts: ${LIVE_HOSTS}${NC}"
else
    echo -e "${YELLOW}[!] httpx not found, using all subdomains${NC}"
    cp subdomains/all_subdomains.txt subdomains/live_hosts.txt
fi
echo ""

# Phase 3: Parameter Discovery
echo -e "${PURPLE}╔════════════════════════════════════════╗${NC}"
echo -e "${PURPLE}║  Phase 3: Parameter Discovery         ║${NC}"
echo -e "${PURPLE}╚════════════════════════════════════════╝${NC}"
echo ""

if check_tool "parameterx"; then
    echo -e "${BLUE}[*] Running ParameterX...${NC}"
    parameterx -s subdomains/live_hosts.txt -o parameters/all_params.txt -w 20
    TOTAL_PARAMS=$(wc -l < parameters/all_params.txt)
    echo -e "${GREEN}[✓] Total parameter URLs: ${TOTAL_PARAMS}${NC}"
else
    echo -e "${RED}[!] ParameterX not found. Please install it first.${NC}"
    exit 1
fi
echo ""

# Phase 4: Parameter Classification
echo -e "${PURPLE}╔════════════════════════════════════════╗${NC}"
echo -e "${PURPLE}║  Phase 4: Vulnerability Classification║${NC}"
echo -e "${PURPLE}╚════════════════════════════════════════╝${NC}"
echo ""

if check_tool "gf"; then
    echo -e "${BLUE}[*] Classifying parameters with gf...${NC}"
    
    cat parameters/all_params.txt | gf xss 2>/dev/null > parameters/xss_candidates.txt || touch parameters/xss_candidates.txt
    XSS_COUNT=$(wc -l < parameters/xss_candidates.txt)
    echo -e "${GREEN}[✓] XSS candidates: ${XSS_COUNT}${NC}"
    
    cat parameters/all_params.txt | gf sqli 2>/dev/null > parameters/sqli_candidates.txt || touch parameters/sqli_candidates.txt
    SQLI_COUNT=$(wc -l < parameters/sqli_candidates.txt)
    echo -e "${GREEN}[✓] SQLi candidates: ${SQLI_COUNT}${NC}"
    
    cat parameters/all_params.txt | gf redirect 2>/dev/null > parameters/redirect_candidates.txt || touch parameters/redirect_candidates.txt
    REDIRECT_COUNT=$(wc -l < parameters/redirect_candidates.txt)
    echo -e "${GREEN}[✓] Open Redirect candidates: ${REDIRECT_COUNT}${NC}"
    
    cat parameters/all_params.txt | gf ssrf 2>/dev/null > parameters/ssrf_candidates.txt || touch parameters/ssrf_candidates.txt
    SSRF_COUNT=$(wc -l < parameters/ssrf_candidates.txt)
    echo -e "${GREEN}[✓] SSRF candidates: ${SSRF_COUNT}${NC}"
else
    echo -e "${YELLOW}[!] gf not found, skipping classification${NC}"
fi
echo ""

# Phase 5: Sensitive Parameter Detection
echo -e "${PURPLE}╔════════════════════════════════════════╗${NC}"
echo -e "${PURPLE}║  Phase 5: Sensitive Parameter Hunt    ║${NC}"
echo -e "${PURPLE}╚════════════════════════════════════════╝${NC}"
echo ""

echo -e "${BLUE}[*] Searching for sensitive parameters...${NC}"

grep -iE "api_?key|api_?token|access_?token|secret|password|passwd|pwd|admin|debug|test" parameters/all_params.txt > parameters/sensitive.txt 2>/dev/null || touch parameters/sensitive.txt
SENSITIVE_COUNT=$(wc -l < parameters/sensitive.txt)
echo -e "${GREEN}[✓] Sensitive parameters: ${SENSITIVE_COUNT}${NC}"

grep -iE "callback|redirect|url|next|return|dest|continue" parameters/all_params.txt > parameters/redirect_params.txt 2>/dev/null || touch parameters/redirect_params.txt
echo -e "${GREEN}[✓] Potential redirect parameters: $(wc -l < parameters/redirect_params.txt)${NC}"

grep -iE "id=|user_?id=|account=|uid=|profile=" parameters/all_params.txt > parameters/idor_params.txt 2>/dev/null || touch parameters/idor_params.txt
echo -e "${GREEN}[✓] Potential IDOR parameters: $(wc -l < parameters/idor_params.txt)${NC}"
echo ""

# Generate Summary Report
echo -e "${PURPLE}╔════════════════════════════════════════╗${NC}"
echo -e "${PURPLE}║  Summary Report                        ║${NC}"
echo -e "${PURPLE}╚════════════════════════════════════════╝${NC}"
echo ""

SUMMARY_FILE="SUMMARY.txt"

cat > "${SUMMARY_FILE}" << EOF
╔═══════════════════════════════════════════════════════════════╗
║              ParameterX Recon Summary Report                  ║
╚═══════════════════════════════════════════════════════════════╝

Target: ${TARGET}
Date: $(date)
Duration: $(date -d@$SECONDS -u +%H:%M:%S)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📊 Statistics:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Total Subdomains Found:      ${TOTAL_SUBS}
Live Hosts:                  ${LIVE_HOSTS}
Parameter URLs Discovered:   ${TOTAL_PARAMS}

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🎯 Vulnerability Candidates:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

XSS Candidates:              ${XSS_COUNT:-0}
SQLi Candidates:             ${SQLI_COUNT:-0}
Open Redirect Candidates:    ${REDIRECT_COUNT:-0}
SSRF Candidates:             ${SSRF_COUNT:-0}
IDOR Candidates:             $(wc -l < parameters/idor_params.txt)
Sensitive Parameters:        ${SENSITIVE_COUNT}

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📁 Output Files:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Subdomains:                  subdomains/all_subdomains.txt
Live Hosts:                  subdomains/live_hosts.txt
All Parameters:              parameters/all_params.txt
XSS Candidates:              parameters/xss_candidates.txt
SQLi Candidates:             parameters/sqli_candidates.txt
Redirect Candidates:         parameters/redirect_candidates.txt
SSRF Candidates:             parameters/ssrf_candidates.txt
IDOR Candidates:             parameters/idor_params.txt
Sensitive Parameters:        parameters/sensitive.txt

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🔍 Next Steps:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

1. Review sensitive parameters manually
2. Fuzz XSS candidates with dalfox or ffuf
3. Test SQLi with sqlmap
4. Check open redirects manually
5. Test IDOR endpoints with different IDs
6. Scan with nuclei for known vulnerabilities

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Generated by ParameterX Workflow
Workspace: ${WORK_DIR}

EOF

cat "${SUMMARY_FILE}"

echo ""
echo -e "${GREEN}╔════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║  Workflow Complete! ✓                  ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════╝${NC}"
echo ""
echo -e "${YELLOW}[*] Results saved in: ${WORK_DIR}${NC}"
echo -e "${YELLOW}[*] Summary: ${WORK_DIR}/${SUMMARY_FILE}${NC}"
echo ""
echo -e "${BLUE}[*] Happy Hunting! 🎯${NC}"
