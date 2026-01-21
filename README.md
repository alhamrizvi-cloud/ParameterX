<img width="751" height="359" alt="image" src="https://github.com/user-attachments/assets/834293f9-fa38-44b1-993c-35a581ff5fa8" />


 
# ParameterX

```

▄▄▄▄  ▗▞▀▜▌ ▄▄▄ ▗▞▀▜▌▄▄▄▄  ▗▞▀▚▖   ■  ▗▞▀▚▖ ▄▄▄ ▄   ▄ 
█   █ ▝▚▄▟▌█    ▝▚▄▟▌█ █ █ ▐▛▀▀▘▗▄▟▙▄▖▐▛▀▀▘█     ▀▄▀  
█▄▄▄▀      █         █   █ ▝▚▄▄▖  ▐▌  ▝▚▄▄▖█    ▄▀ ▀▄ 
█                                 ▐▌                  
▀                                 ▐▌                                                            
                                                        
        Passive URL Parameter Discovery Tool
```

[![Go Version](https://img.shields.io/badge/Go-1.19+-00ADD8?style=flat&logo=go)](https://golang.org)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![GitHub Stars](https://img.shields.io/github/stars/alhamrizvi-cloud/ParameterX?style=social)](https://github.com/alhamrizvi-cloud/ParameterX/stargazers)

**ParameterX** is a powerful passive reconnaissance tool that extracts historical URL parameters from public web archives without touching the live target. Perfect for bug bounty hunters and security researchers.

## 🎯 Features

- **🔍 100% Passive Reconnaissance** - No requests sent to target domains
- **📚 Multiple Archive Sources** - Queries Wayback Machine, Archive.org, and Common Crawl
- **⚡ Fast & Concurrent** - Multi-threaded processing with configurable workers
- **🎯 Smart Filtering** - Automatic exclusion of static files (images, CSS, JS)
- **🔄 Parameter Normalization** - Replaces values with custom placeholders (FUZZ)
- **📊 Subdomain Support** - Process entire subdomain lists at once
- **💾 Flexible Output** - Save results or print to stdout

## 🚀 Installation

### From Source

```bash
git clone https://github.com/alhamrizvi-cloud/ParameterX.git
cd ParameterX
go build -o parameterx main.go
sudo mv parameterx /usr/local/bin/
```

### Using Go Install

```bash
go install github.com/alhamrizvi-cloud/ParameterX@latest
```

## 📖 Usage

### Basic Usage

```bash
# Single domain
parameterx -d example.com -o output.txt

# Multiple domains from file
parameterx -l domains.txt -o output.txt

# Process subdomains
parameterx -s subdomains.txt -o params.txt
```

### Advanced Options

```bash
# Increase workers for faster processing
parameterx -d example.com -w 20 -o output.txt

# Verbose mode
parameterx -d example.com -v -o output.txt

# Custom placeholder for fuzzing
parameterx -d example.com -placeholder PAYLOAD -o fuzz.txt

# Silent mode (no banner)
parameterx -d example.com -silent -o output.txt

# Custom file exclusions
parameterx -d example.com -exclude "jpg,png,pdf,zip" -o output.txt
```

## 🔧 Command Line Options

```
  -d string
        Target domain (e.g., example.com)
  -l string
        File containing list of domains
  -s string
        File containing list of subdomains
  -o string
        Output file path
  -w int
        Number of concurrent workers (default: 10)
  -placeholder string
        Placeholder for parameter values (default: "FUZZ")
  -exclude string
        Comma-separated extensions to exclude (default: "jpg,jpeg,png,gif,css,js,svg,woff,woff2,ttf,eot,ico")
  -v    Verbose output
  -silent
        Silent mode (no banner)
```

## 📊 Data Sources

ParameterX queries the following passive sources:

| Source | Description | Coverage |
|--------|-------------|----------|
| **Wayback Machine** | Internet Archive CDX API | Historical snapshots |
| **Archive.org** | Alternative text format API | Extended coverage |
| **Common Crawl** | Large-scale web crawl data | Multiple indexes |

## 🎯 Bug Bounty Workflow

```bash
# Step 1: Subdomain enumeration
subfinder -d target.com -o subdomains.txt

# Step 2: Parameter discovery
parameterx -s subdomains.txt -o params.txt

# Step 3: Filter for specific vulnerabilities
cat params.txt | gf xss > xss_params.txt
cat params.txt | gf sqli > sqli_params.txt
cat params.txt | gf redirect > redirect_params.txt

# Step 4: Fuzz with ffuf
ffuf -u FUZZ -w xss_params.txt -mc 200

# Step 5: Manual validation with Burp Suite
```

## 🔍 Common Vulnerabilities Found

| Vulnerability | Parameter Examples | Why ParameterX Helps |
|---------------|-------------------|---------------------|
| **XSS** | `q`, `search`, `query` | Finds old reflected parameters |
| **Open Redirect** | `url`, `redirect`, `next` | Discovers redirect endpoints |
| **IDOR** | `id`, `user_id`, `account` | Reveals API endpoints |
| **SSRF** | `callback`, `webhook`, `url` | Identifies callback parameters |
| **Debug Leaks** | `debug`, `test`, `dev` | Exposes debug endpoints |

## 📁 Example Output

```
https://example.com/search?q=FUZZ
https://api.example.com/user?id=FUZZ
https://example.com/redirect?url=FUZZ
https://admin.example.com/export?debug=FUZZ
https://example.com/callback?webhook=FUZZ
```

## 🛠️ Integration with Other Tools

### With httpx
```bash
parameterx -s subs.txt -o params.txt
cat params.txt | httpx -mc 200 -o live.txt
```

### With nuclei
```bash
parameterx -d target.com -o params.txt
nuclei -l params.txt -t xss/
```

### With meg
```bash
parameterx -s subs.txt -o params.txt
meg --verbose paths.txt params.txt output/
```

## 📝 Input File Formats

### domains.txt
```
example.com
target.com
test.com
```

### subdomains.txt
```
api.example.com
admin.example.com
dev.example.com
https://mail.example.com
http://blog.example.com/
```

## 🎓 How It Works

1. **📥 Input Processing** - Reads domain/subdomain lists
2. **🌐 Archive Querying** - Sends requests to Wayback, Archive.org, Common Crawl
3. **📊 URL Collection** - Gathers historical URLs with parameters
4. **🔎 Parameter Extraction** - Parses query strings and extracts parameter names
5. **🔄 Normalization** - Replaces values with placeholders (FUZZ)
6. **📤 Output Generation** - Saves deduplicated results

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📜 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👨‍💻 Author

**Alham Rizvi** ([@alhamrizvi-cloud](https://github.com/alhamrizvi-cloud))

## ⭐ Support

If you found this tool helpful, please consider giving it a star ⭐

## 🙏 Acknowledgments

- Internet Archive for Wayback Machine API
- Common Crawl for web crawl data
- The bug bounty community for feedback and support

## 📞 Contact

- GitHub: [@alhamrizvi-cloud](https://github.com/alhamrizvi-cloud)
- Tool: [ParameterX](https://github.com/alhamrizvi-cloud/ParameterX)

## ⚠️ Disclaimer

This tool is intended for security research and authorized testing only. Users are responsible for complying with applicable laws and regulations. The author assumes no liability for misuse.

---

**Made with ❤️ by Alham Rizvi**
