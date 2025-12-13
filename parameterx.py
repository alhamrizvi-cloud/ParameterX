#!/usr/bin/env python3
"""
====================================================
 ParameterX - Parameter Discovery & Analysis Tool
----------------------------------------------------
 Description:
 ParameterX is a junior-friendly web security tool
 designed to discover HTTP parameters and analyze
 their behavior to help identify potential logic
 flaws such as IDOR, parameter tampering, and
 hidden parameters.

 The tool focuses on:
  - URL parameter discovery
  - HTML form parameter extraction
  - Common hidden parameter testing
  - Behavioral analysis using response comparison

 This tool is intended for LEGAL testing only
 (labs, CTFs, and authorized targets).

 Made by: Alham Rizvi
====================================================
"""

# ======================
# ASCII ART BANNER
# ======================
BANNER = r"""
██████╗  █████╗ ██████╗  █████╗ ███╗   ███╗███████╗████████╗███████╗██████╗ ██╗  ██╗
██╔══██╗██╔══██╗██╔══██╗██╔══██╗████╗ ████║██╔════╝╚══██╔══╝██╔════╝██╔══██╗╚██╗██╔╝
██████╔╝███████║██████╔╝███████║██╔████╔██║█████╗     ██║   █████╗  ██████╔╝ ╚███╔╝ 
██╔═══╝ ██╔══██║██╔══██╗██╔══██║██║╚██╔╝██║██╔══╝     ██║   ██╔══╝  ██╔══██╗ ██╔██╗ 
██║     ██║  ██║██║  ██║██║  ██║██║ ╚═╝ ██║███████╗   ██║   ███████╗██║  ██║██╔╝ ██╗
╚═╝     ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝     ╚═╝╚══════╝   ╚═╝   ╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝
"""

# ======================
# Imports
# ======================
import requests
import argparse
import json
import logging
from urllib.parse import urlparse, parse_qs
from bs4 import BeautifulSoup
from difflib import SequenceMatcher
from enum import Enum

# ======================
# Configuration
# ======================
HEADERS = {
    "User-Agent": "ParameterX/1.0"
}

TIMEOUT = 6

COMMON_PARAMS = [
    # Identification / Object References
    "id", "user_id", "uid", "account", "account_id", "profile_id",
    "order_id", "item_id", "product_id", "invoice_id", "payment_id",
    "transaction_id", "file_id", "document_id", "record_id",

    # Authentication / Session
    "token", "access_token", "auth_token", "refresh_token",
    "session", "session_id", "session_key", "sid", "jwt",
    "csrf", "csrf_token", "xsrf", "xsrf_token",

    # Authorization / Roles
    "role", "roles", "permission", "permissions",
    "isAdmin", "admin", "is_admin", "isStaff", "staff",
    "isManager", "manager", "privilege", "access_level",

    # User Information
    "username", "user", "email", "phone", "mobile",
    "firstname", "lastname", "fullname", "display_name",
    "password", "old_password", "new_password",

    # Application Logic
    "status", "state", "type", "category", "level",
    "mode", "action", "step", "stage", "flow",
    "enabled", "disabled", "active", "inactive",

    # Debug / Dev
    "debug", "test", "testing", "dev", "development",
    "verbose", "trace", "error", "stacktrace",

    # Pagination / Filtering
    "page", "page_id", "page_no", "limit", "offset",
    "sort", "order", "order_by", "filter", "search", "q",

    # Feature Flags / Toggles
    "feature", "feature_flag", "flag", "beta",
    "preview", "experimental",

    # Redirects / URLs
    "redirect", "redirect_url", "return", "return_url",
    "next", "next_url", "callback", "callback_url",

    # Files / Uploads
    "file", "filename", "filepath", "path", "upload",
    "download", "attachment",

    # Misc / Common Logic Flaws
    "amount", "price", "total", "balance", "discount",
    "currency", "quantity", "count",
    "verified", "confirmed", "approved", "deleted"
]


logging.basicConfig(
    level=logging.INFO,
    format="%(levelname)s: %(message)s"
)

# ======================
# Risk Levels
# ======================
class Risk(Enum):
    LOW = "Low"
    MEDIUM = "Medium"
    HIGH = "High"

# ======================
# Core Classes
# ======================
class Requester:
    """Handles HTTP requests safely"""

    @staticmethod
    def get(url, params=None):
        try:
            return requests.get(
                url,
                params=params,
                headers=HEADERS,
                timeout=TIMEOUT
            )
        except requests.RequestException as e:
            logging.warning(f"Request failed: {e}")
            return None

class ParameterExtractor:
    """Extract parameters from different sources"""

    @staticmethod
    def from_url(url):
        parsed = urlparse(url)
        return list(parse_qs(parsed.query).keys())

    @staticmethod
    def from_html(response):
        params = []
        try:
            soup = BeautifulSoup(response.text, "html.parser")
            for form in soup.find_all("form"):
                for input_tag in form.find_all("input"):
                    name = input_tag.get("name")
                    if name:
                        params.append(name)
        except Exception:
            pass
        return params

    @staticmethod
    def from_wordlist():
        return COMMON_PARAMS

class ResponseComparator:
    """Compare responses to detect behavior change"""

    @staticmethod
    def similarity(a, b):
        return SequenceMatcher(None, a, b).ratio()

class ParameterAnalyzer:
    """Analyze parameter behavior"""

    def __init__(self, requester):
        self.requester = requester

    def test_removal(self, url, param):
        parsed = urlparse(url)
        params = parse_qs(parsed.query)
        params.pop(param, None)
        base_url = parsed._replace(query="").geturl()
        response = self.requester.get(base_url, params=params)
        return response.text if response else ""

# ======================
# Main Workflow
# ======================
def main():
    print(BANNER)
    print("ParameterX - Parameter Discovery Tool")
    print("Made by Alham Rizvi\n")

    parser = argparse.ArgumentParser(
        description="ParameterX - Discover and analyze HTTP parameters"
    )
    parser.add_argument("url", help="Target URL (with parameters)")
    args = parser.parse_args()

    url = args.url
    requester = Requester()
    extractor = ParameterExtractor()
    analyzer = ParameterAnalyzer(requester)

    logging.info("Sending base request...")
    base_response = requester.get(url)
    if not base_response:
        logging.error("Could not fetch target URL")
        return

    # Step 1: Parameter discovery
    logging.info("Discovering parameters...")
    url_params = extractor.from_url(url)
    html_params = extractor.from_html(base_response)
    wordlist_params = extractor.from_wordlist()

    all_params = list(set(url_params + html_params + wordlist_params))
    logging.info(f"Parameters found: {all_params}")

    findings = []

    # Step 2: Parameter analysis
    for param in all_params:
        logging.info(f"Analyzing parameter: {param}")
        removed_response = analyzer.test_removal(url, param)

        similarity = ResponseComparator.similarity(
            base_response.text,
            removed_response
        )

        if similarity < 0.90:
            risk = Risk.HIGH
        elif similarity < 0.97:
            risk = Risk.MEDIUM
        else:
            risk = Risk.LOW

        findings.append({
            "endpoint": url,
            "parameter": param,
            "test": "parameter_removal",
            "similarity_score": round(similarity, 2),
            "risk": risk.value
        })

    # Step 3: Output
    print("\n=== Findings ===")
    print(json.dumps(findings, indent=4))

    with open("parameterx_report.json", "w") as f:
        json.dump(findings, f, indent=4)

    logging.info("Report saved as parameterx_report.json")

# ======================
# Entry Point
# ======================
if __name__ == "__main__":
    main()
