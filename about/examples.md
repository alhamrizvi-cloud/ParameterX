# ParameterX - Usage Examples

## 📚 Table of Contents

- [Basic Usage](#basic-usage)
- [Advanced Usage](#advanced-usage)
- [Bug Bounty Workflows](#bug-bounty-workflows)
- [Integration Examples](#integration-examples)
- [Output Examples](#output-examples)

## Basic Usage

### 1. Single Domain Scan

```bash
parameterx -d example.com -o params.txt
```

**Output:**
```
[*] Processing 1 domain(s)
[*] Processing: example.com
[+] example.com: Found 245 URLs with parameters from Wayback/Archive.org
[+] example.com: Found 89 URLs with parameters from Common Crawl
[✓] example.com: Completed parameter extraction
[✓] Results saved to: params.txt

[✓] Found 127 unique parameters
[✓] Generated 334 unique URLs
```

### 2. Multiple Domains

```bash
# Create domains.txt
echo "example.com" > domains.txt
echo "target.com" >> domains.txt
echo "test.com" >> domains.txt

# Run scan
parameterx -l domains.txt -o output.txt
```

### 3. Subdomain List

```bash
# Use subfinder to get subdomains first
subfinder -d example.com -silent > subdomains.txt

# Scan all subdomains
parameterx -s subdomains.txt -o params.txt
```

## Advanced Usage

### 4. High-Speed Scanning

```bash
# Use 50 concurrent workers
parameterx -d example.com -w 50 -o fast_results.txt
```

### 5. Custom Placeholder for Fuzzing

```bash
# Replace parameter values with custom string
parameterx -d example.com -placeholder "PAYLOAD" -o fuzz.txt
```

**Output in fuzz.txt:**
```
https://example.com/search?q=PAYLOAD
https://api.example.com/user?id=PAYLOAD
```

### 6. Verbose Mode for Debugging

```bash
parameterx -d example.com -v -o output.txt
```

**Verbose Output:**
```
[V] Querying Wayback CDX: https://web.archive.org/cdx/search/cdx?url=*.example.com/*
[V] Querying Archive.org text: https://web.archive.org/cdx/search/cdx?url=example.com/*
[V] Querying Wayback wildcard: https://web.archive.org/cdx/search/cdx?url=*.example.com/*
[V] Querying Common Crawl CC-MAIN-2024-10: https://index.commoncrawl.org/...
```

### 7. Silent Mode (No Banner)

```bash
parameterx -d example.com -silent -o output.txt
```

### 8. Custom File Exclusions

```bash
# Exclude additional file types
parameterx -d example.com -exclude "jpg,png,pdf,zip,doc,docx" -o output.txt
```

## Bug Bounty Workflows

### 9. Complete Recon Workflow

```bash
#!/bin/bash

TARGET="example.com"

# Step 1: Subdomain enumeration
echo "[*] Finding subdomains..."
subfinder -d $TARGET -silent | tee subdomains.txt
httpx -l subdomains.txt -silent -mc 200 -o live_subs.txt

# Step 2: Parameter discovery
echo "[*] Extracting parameters..."
parameterx -s live_subs.txt -o all_params.txt

# Step 3: Filter by vulnerability type
echo "[*] Filtering parameters..."
cat all_params.txt | gf xss | tee xss_params.txt
cat all_params.txt | gf sqli | tee sqli_params.txt
cat all_params.txt | gf redirect | tee redirect_params.txt
cat all_params.txt | gf ssrf | tee ssrf_params.txt

# Step 4: Count findings
echo "[*] Results:"
echo "  XSS candidates: $(wc -l < xss_params.txt)"
echo "  SQLi candidates: $(wc -l < sqli_params.txt)"
echo "  Redirect candidates: $(wc -l < redirect_params.txt)"
echo "  SSRF candidates: $(wc -l < ssrf_params.txt)"
```

### 10. XSS Hunting Pipeline

```bash
# Get parameters
parameterx -d example.com -o params.txt

# Filter for XSS-prone parameters
cat params.txt | gf xss > xss_candidates.txt

# Test with dalfox
cat xss_candidates.txt | dalfox pipe -o xss_results.txt

# Or use ffuf with XSS payloads
ffuf -u FUZZ -w xss_candidates.txt -w xss_payloads.txt:PAYLOAD -mc 200
```

### 11. IDOR Discovery

```bash
# Find API endpoints with ID parameters
parameterx -d api.example.com -o api_params.txt

# Filter for IDOR candidates
grep -E "id=|user_id=|account=|uid=|profile=" api_params.txt > idor_candidates.txt

# Test with different ID values
cat idor_candidates.txt | sed 's/FUZZ/1/g' > test_ids.txt
```

### 12. Open Redirect Hunting

```bash
# Extract redirect parameters
parameterx -d example.com -o params.txt
cat params.txt | gf redirect > redirects.txt

# Test with redirect payloads
while read url; do
    echo "Testing: $url"
    curl -s -I "${url/FUZZ/https://evil.com}" | grep -i location
done < redirects.txt
```

## Integration Examples

### 13. With httpx for Live Testing

```bash
# Get parameters and check which are live
parameterx -d example.com -o params.txt
cat params.txt | httpx -mc 200,301,302 -o live_params.txt
```

### 14. With Nuclei for Vulnerability Scanning

```bash
parameterx -d example.com -o params.txt
nuclei -l params.txt -t nuclei-templates/ -o vulnerabilities.txt
```

### 15. With meg for Mass Testing

```bash
# Create paths file
echo "/admin?debug=FUZZ" > paths.txt
echo "/api/user?id=FUZZ" >> paths.txt

# Get targets
parameterx -s subdomains.txt -o params.txt

# Test with meg
meg --verbose paths.txt params.txt output/
```

### 16. With Burp Suite

```bash
# Extract parameters
parameterx -d example.com -o params.txt

# Convert to Burp format (remove FUZZ, add to Intruder)
sed 's/FUZZ/§§/g' params.txt > burp_targets.txt
```

### 17. With FFUF Fuzzing

```bash
# Get parameters
parameterx -d example.com -placeholder "FUZZ" -o targets.txt

# Fuzz with wordlist
ffuf -u FUZZ -w targets.txt -w payloads.txt:PAYLOAD -mc 200 -fc 404
```

### 18. Combine Multiple Sources

```bash
#!/bin/bash

TARGET="example.com"

# Method 1: ParameterX
parameterx -d $TARGET -o px_params.txt

# Method 2: gau
echo $TARGET | gau > gau_urls.txt

# Method 3: waybackurls
echo $TARGET | waybackurls > wb_urls.txt

# Combine and deduplicate
cat px_params.txt gau_urls.txt wb_urls.txt | sort -u > all_urls.txt
echo "[+] Total unique URLs: $(wc -l < all_urls.txt)"
```

## Output Examples

### 19. Standard Output Format

```
https://example.com/search?q=FUZZ
https://example.com/login?redirect=FUZZ
https://api.example.com/user?id=FUZZ&format=FUZZ
https://example.com/page?section=FUZZ&lang=FUZZ
https://admin.example.com/export?debug=FUZZ&verbose=FUZZ
```

### 20. Grep for Specific Parameters

```bash
# Find all debug parameters
parameterx -d example.com -o params.txt
grep "debug=" params.txt

# Find all admin paths
grep "admin" params.txt

# Find API endpoints
grep "api\." params.txt
```

### 21. Extract Only Parameter Names

```bash
parameterx -d example.com -o params.txt
cat params.txt | sed 's/.*?//; s/=[^&]*//g; s/&/\n/g' | sort -u > param_names.txt
```

**Output (param_names.txt):**
```
callback
debug
format
id
lang
next
q
redirect
section
token
url
user_id
verbose
```

### 22. Statistics and Analysis

```bash
# Count total URLs
wc -l params.txt

# Count unique parameters
cat params.txt | grep -oP '\?.*' | tr '&' '\n' | cut -d= -f1 | sort -u | wc -l

# Most common parameters
cat params.txt | grep -oP '\?.*' | tr '&' '\n' | cut -d= -f1 | sort | uniq -c | sort -rn | head -20

# Find sensitive-looking parameters
grep -E "key=|token=|secret=|api=|pass=|admin=" params.txt
```

## Advanced Scenarios

### 23. Rate-Limited Scanning

```bash
# Slow down scanning for sensitive targets
parameterx -d example.com -w 3 -o params.txt
```

### 24. Automated Daily Scan

```bash
#!/bin/bash
# Save as daily_scan.sh

DATE=$(date +%Y-%m-%d)
TARGET="example.com"
OUTPUT_DIR="/home/user/recon/$TARGET"

mkdir -p $OUTPUT_DIR

echo "[*] Starting daily scan for $TARGET - $DATE"
parameterx -d $TARGET -o "$OUTPUT_DIR/params_$DATE.txt"

# Compare with yesterday
YESTERDAY=$(date -d "yesterday" +%Y-%m-%d)
if [ -f "$OUTPUT_DIR/params_$YESTERDAY.txt" ]; then
    diff "$OUTPUT_DIR/params_$YESTERDAY.txt" "$OUTPUT_DIR/params_$DATE.txt" > "$OUTPUT_DIR/diff_$DATE.txt"
    echo "[*] New parameters found: $(grep "^>" "$OUTPUT_DIR/diff_$DATE.txt" | wc -l)"
fi
```

### 25. Multi-Target Campaign

```bash
#!/bin/bash
# Scan multiple bug bounty programs

PROGRAMS=(
    "hackerone.com"
    "bugcrowd.com"
    "example.com"
)

for program in "${PROGRAMS[@]}"; do
    echo "[*] Scanning $program"
    parameterx -d $program -o "${program}_params.txt" -w 20
    echo "[✓] Completed $program"
    sleep 5
done

echo "[✓] All programs scanned"
```

---

## 💡 Tips & Tricks

1. **Always start with subdomain enumeration** before running ParameterX
2. **Use the `-v` flag** when debugging or verifying results
3. **Combine with other tools** like gf, httpx, and nuclei for best results
4. **Save outputs with dates** for tracking new parameters over time
5. **Use higher worker counts** (`-w 30+`) for faster results on stable networks
6. **Filter results immediately** with gf or grep to focus on specific vulnerabilities
7. **Test live URLs first** with httpx before fuzzing to avoid false positives

---

**Made with ❤️ by Ilham Rizvi**
