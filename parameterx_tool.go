package main

import (
	"bufio"
	"encoding/json"
	"flag"
	"fmt"
	"io"
	"net/http"
	"net/url"
	"os"
	"strings"
	"sync"
	"time"
)

const banner = `
 ____                                _            __  __
|  _ \ __ _ _ __ __ _ _ __ ___   ___| |_ ___ _ __\ \/ /
| |_) / _' | '__/ _' | '_ ' _ \ / _ \ __/ _ \ '__|\  / 
|  __/ (_| | | | (_| | | | | | |  __/ ||  __/ |   /  \ 
|_|   \__,_|_|  \__,_|_| |_| |_|\___|\__\___|_|  /_/\_\
                                                        
        Passive URL Parameter Discovery Tool
              By: Security Researchers
                 Version: 1.0.0
`

type Config struct {
	Domain        string
	DomainList    string
	SubdomainList string
	Output        string
	Exclude       string
	Workers       int
	Placeholder   string
	Silent        bool
	Verbose       bool
}

type WaybackResponse struct {
	URL string `json:"url"`
}

var (
	excludeExts = make(map[string]bool)
	paramSet    = make(map[string]bool)
	urlSet      = make(map[string]bool)
	mu          sync.Mutex
)

func main() {
	cfg := parseFlags()

	if !cfg.Silent {
		fmt.Println(banner)
	}

	// Parse exclude extensions
	if cfg.Exclude != "" {
		for _, ext := range strings.Split(cfg.Exclude, ",") {
			excludeExts[strings.TrimSpace(ext)] = true
		}
	}

	// Get domains to process
	domains := getDomains(cfg)
	if len(domains) == 0 {
		fmt.Println("[!] No domains to process")
		os.Exit(1)
	}

	fmt.Printf("[*] Processing %d domain(s)\n", len(domains))

	// Process domains
	var wg sync.WaitGroup
	semaphore := make(chan struct{}, cfg.Workers)

	for _, domain := range domains {
		wg.Add(1)
		semaphore <- struct{}{}

		go func(d string) {
			defer wg.Done()
			defer func() { <-semaphore }()

			processDomain(d, cfg)
		}(domain)
	}

	wg.Wait()

	// Output results
	outputResults(cfg)

	fmt.Printf("\n[✓] Found %d unique parameters\n", len(paramSet))
	fmt.Printf("[✓] Generated %d unique URLs\n", len(urlSet))
}

func parseFlags() Config {
	cfg := Config{}

	flag.StringVar(&cfg.Domain, "d", "", "Target domain")
	flag.StringVar(&cfg.DomainList, "l", "", "File containing list of domains")
	flag.StringVar(&cfg.SubdomainList, "s", "", "File containing list of subdomains")
	flag.StringVar(&cfg.Output, "o", "", "Output file")
	flag.StringVar(&cfg.Exclude, "exclude", "jpg,jpeg,png,gif,css,js,svg,woff,woff2,ttf,eot,ico", "Comma-separated extensions to exclude")
	flag.IntVar(&cfg.Workers, "w", 10, "Number of concurrent workers")
	flag.StringVar(&cfg.Placeholder, "placeholder", "FUZZ", "Placeholder for parameter values")
	flag.BoolVar(&cfg.Silent, "silent", false, "Silent mode (no banner)")
	flag.BoolVar(&cfg.Verbose, "v", false, "Verbose output")

	flag.Parse()

	if cfg.Domain == "" && cfg.DomainList == "" && cfg.SubdomainList == "" {
		fmt.Println("\nUsage:")
		fmt.Println("  parameterx -d example.com -o output.txt")
		fmt.Println("  parameterx -l domains.txt -o output.txt")
		fmt.Println("  parameterx -s subdomains.txt -o output.txt")
		fmt.Println("\nOptions:")
		flag.PrintDefaults()
		os.Exit(1)
	}

	return cfg
}

func getDomains(cfg Config) []string {
	var domains []string

	if cfg.Domain != "" {
		domains = append(domains, cfg.Domain)
	}

	if cfg.DomainList != "" {
		file, err := os.Open(cfg.DomainList)
		if err != nil {
			fmt.Printf("[!] Error reading domain list: %v\n", err)
			return domains
		}
		defer file.Close()

		scanner := bufio.NewScanner(file)
		for scanner.Scan() {
			domain := strings.TrimSpace(scanner.Text())
			if domain != "" && !strings.HasPrefix(domain, "#") {
				domains = append(domains, domain)
			}
		}
	}

	if cfg.SubdomainList != "" {
		file, err := os.Open(cfg.SubdomainList)
		if err != nil {
			fmt.Printf("[!] Error reading subdomain list: %v\n", err)
			return domains
		}
		defer file.Close()

		scanner := bufio.NewScanner(file)
		for scanner.Scan() {
			subdomain := strings.TrimSpace(scanner.Text())
			if subdomain != "" && !strings.HasPrefix(subdomain, "#") {
				// Remove protocol if present
				subdomain = strings.TrimPrefix(subdomain, "http://")
				subdomain = strings.TrimPrefix(subdomain, "https://")
				// Remove trailing slash
				subdomain = strings.TrimSuffix(subdomain, "/")
				domains = append(domains, subdomain)
			}
		}
	}

	return domains
}

func processDomain(domain string, cfg Config) {
	fmt.Printf("[*] Processing: %s\n", domain)

	var allURLs []string

	// Query Wayback Machine & Archive.org
	urls := queryWayback(domain, cfg)
	fmt.Printf("[+] %s: Found %d URLs with parameters from Wayback/Archive.org\n", domain, len(urls))
	allURLs = append(allURLs, urls...)

	// Query Common Crawl
	ccUrls := queryCommonCrawl(domain, cfg)
	if len(ccUrls) > 0 {
		fmt.Printf("[+] %s: Found %d URLs with parameters from Common Crawl\n", domain, len(ccUrls))
		allURLs = append(allURLs, ccUrls...)
	}

	// Extract parameters
	if len(allURLs) > 0 {
		extractParameters(allURLs, cfg)
		fmt.Printf("[✓] %s: Completed parameter extraction\n", domain)
	} else {
		fmt.Printf("[!] %s: No URLs with parameters found\n", domain)
	}
}

func queryWayback(domain string, cfg Config) []string {
	var results []string
	seen := make(map[string]bool)

	// Method 1: CDX API (JSON)
	apiURL := fmt.Sprintf("https://web.archive.org/cdx/search/cdx?url=*.%s/*&output=json&fl=original&collapse=urlkey", domain)

	if cfg.Verbose {
		fmt.Printf("[V] Querying Wayback CDX: %s\n", apiURL)
	}

	client := &http.Client{Timeout: 60 * time.Second}
	resp, err := client.Get(apiURL)
	if err != nil {
		fmt.Printf("[!] Wayback CDX query failed for %s: %v\n", domain, err)
	} else {
		defer resp.Body.Close()

		body, err := io.ReadAll(resp.Body)
		if err == nil {
			var data [][]string
			if err := json.Unmarshal(body, &data); err == nil {
				for i, row := range data {
					if i == 0 {
						continue // Skip header
					}
					if len(row) > 0 && !seen[row[0]] {
						// Only include URLs with parameters
						if strings.Contains(row[0], "?") {
							results = append(results, row[0])
							seen[row[0]] = true
						}
					}
				}
			}
		}
	}

	// Method 2: Archive.org text format (alternative API)
	textURL := fmt.Sprintf("https://web.archive.org/cdx/search/cdx?url=%s/*&output=text&fl=original&collapse=urlkey&filter=statuscode:200", domain)
	
	if cfg.Verbose {
		fmt.Printf("[V] Querying Archive.org text: %s\n", textURL)
	}

	resp2, err := client.Get(textURL)
	if err == nil {
		defer resp2.Body.Close()
		
		scanner := bufio.NewScanner(resp2.Body)
		for scanner.Scan() {
			urlStr := strings.TrimSpace(scanner.Text())
			if urlStr != "" && !seen[urlStr] && strings.Contains(urlStr, "?") {
				results = append(results, urlStr)
				seen[urlStr] = true
			}
		}
	}

	// Method 3: Direct wildcard subdomain search
	wildcardURL := fmt.Sprintf("https://web.archive.org/cdx/search/cdx?url=*.%s/*&matchType=domain&output=json&fl=original&collapse=urlkey&filter=statuscode:200", domain)
	
	if cfg.Verbose {
		fmt.Printf("[V] Querying Wayback wildcard: %s\n", wildcardURL)
	}

	resp3, err := client.Get(wildcardURL)
	if err == nil {
		defer resp3.Body.Close()
		
		body, err := io.ReadAll(resp3.Body)
		if err == nil {
			var data [][]string
			if err := json.Unmarshal(body, &data); err == nil {
				for i, row := range data {
					if i == 0 {
						continue
					}
					if len(row) > 0 && !seen[row[0]] && strings.Contains(row[0], "?") {
						results = append(results, row[0])
						seen[row[0]] = true
					}
				}
			}
		}
	}

	return results
}

func queryCommonCrawl(domain string, cfg Config) []string {
	var results []string
	seen := make(map[string]bool)

	// Use the latest Common Crawl index
	indexes := []string{
		"CC-MAIN-2024-10",
		"CC-MAIN-2024-05",
		"CC-MAIN-2023-50",
	}

	client := &http.Client{Timeout: 60 * time.Second}

	for _, index := range indexes {
		apiURL := fmt.Sprintf("https://index.commoncrawl.org/%s-index?url=*.%s/*&output=json", index, domain)

		if cfg.Verbose {
			fmt.Printf("[V] Querying Common Crawl %s: %s\n", index, apiURL)
		}

		resp, err := client.Get(apiURL)
		if err != nil {
			if cfg.Verbose {
				fmt.Printf("[!] Common Crawl %s query failed for %s: %v\n", index, domain, err)
			}
			continue
		}

		scanner := bufio.NewScanner(resp.Body)
		for scanner.Scan() {
			var record map[string]interface{}
			if err := json.Unmarshal(scanner.Bytes(), &record); err == nil {
				if urlStr, ok := record["url"].(string); ok {
					// Only include URLs with parameters
					if strings.Contains(urlStr, "?") && !seen[urlStr] {
						results = append(results, urlStr)
						seen[urlStr] = true
					}
				}
			}
		}
		resp.Body.Close()

		// Limit to prevent excessive API calls
		if len(results) > 5000 {
			break
		}
	}

	return results
}

func extractParameters(urls []string, cfg Config) {
	for _, urlStr := range urls {
		// Check if should be excluded
		if shouldExclude(urlStr) {
			continue
		}

		parsedURL, err := url.Parse(urlStr)
		if err != nil {
			continue
		}

		// Extract parameters
		params := parsedURL.Query()
		if len(params) == 0 {
			continue
		}

		// Build normalized URL
		normalizedURL := buildNormalizedURL(parsedURL, params, cfg.Placeholder)

		mu.Lock()
		for param := range params {
			paramSet[param] = true
		}
		urlSet[normalizedURL] = true
		mu.Unlock()
	}
}

func shouldExclude(urlStr string) bool {
	for ext := range excludeExts {
		if strings.HasSuffix(strings.ToLower(urlStr), "."+ext) {
			return true
		}
	}
	return false
}

func buildNormalizedURL(parsedURL *url.URL, params url.Values, placeholder string) string {
	newParams := url.Values{}
	for key := range params {
		newParams.Set(key, placeholder)
	}

	parsedURL.RawQuery = newParams.Encode()
	return parsedURL.String()
}

func outputResults(cfg Config) {
	var output []string

	mu.Lock()
	for urlStr := range urlSet {
		output = append(output, urlStr)
	}
	mu.Unlock()

	if cfg.Output != "" {
		file, err := os.Create(cfg.Output)
		if err != nil {
			fmt.Printf("[!] Error creating output file: %v\n", err)
			return
		}
		defer file.Close()

		writer := bufio.NewWriter(file)
		for _, line := range output {
			fmt.Fprintln(writer, line)
		}
		writer.Flush()

		fmt.Printf("[✓] Results saved to: %s\n", cfg.Output)
	} else {
		fmt.Println("\n[*] Results:")
		for _, line := range output {
			fmt.Println(line)
		}
	}
}
