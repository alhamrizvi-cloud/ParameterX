# Contributing to ParameterX

First off, thank you for considering contributing to ParameterX! 🎉

## 📋 Table of Contents

- [Code of Conduct](#code-of-conduct)
- [How Can I Contribute?](#how-can-i-contribute)
- [Development Setup](#development-setup)
- [Pull Request Process](#pull-request-process)
- [Coding Standards](#coding-standards)
- [Testing Guidelines](#testing-guidelines)

## Code of Conduct

This project and everyone participating in it is governed by our Code of Conduct. By participating, you are expected to uphold this code. Please report unacceptable behavior to the project maintainers.

### Our Standards

- **Be respectful** and inclusive
- **Be collaborative** and constructive
- **Focus on what is best** for the community
- **Show empathy** towards other community members

## How Can I Contribute?

### 🐛 Reporting Bugs

Before creating bug reports, please check existing issues to avoid duplicates.

**When filing a bug report, include:**

- **Clear title and description**
- **Steps to reproduce** the behavior
- **Expected behavior**
- **Actual behavior**
- **Screenshots** if applicable
- **Environment details:**
  - OS (Linux, macOS, Windows)
  - Go version (`go version`)
  - ParameterX version
  - Command used

**Example Bug Report:**

```markdown
### Bug: ParameterX fails on domains with Unicode characters

**Environment:**
- OS: Ubuntu 22.04
- Go: 1.21.0
- ParameterX: v1.0.0

**Steps to Reproduce:**
1. Run: `parameterx -d exämple.com -o output.txt`
2. Observe error

**Expected:** Should handle Unicode domains
**Actual:** Returns error: "invalid domain format"

**Error Output:**
```
[!] Error processing domain: ...
```

### 💡 Suggesting Enhancements

Enhancement suggestions are tracked as GitHub issues.

**When suggesting an enhancement, include:**

- **Clear use case** - Why is this needed?
- **Detailed description** - What should it do?
- **Examples** - How would it work?
- **Alternatives considered** - What other approaches did you think about?

### 🔧 Pull Requests

We actively welcome your pull requests!

**Good first issues** are labeled `good first issue` - perfect for newcomers!

## Development Setup

### Prerequisites

- Go 1.19 or higher
- Git
- Basic understanding of Go and HTTP APIs

### Setup Instructions

1. **Fork the repository**

```bash
# Click "Fork" on GitHub
```

2. **Clone your fork**

```bash
git clone https://github.com/YOUR_USERNAME/ParameterX.git
cd ParameterX
```

3. **Add upstream remote**

```bash
git remote add upstream https://github.com/alhamrizvi-cloud/ParameterX.git
```

4. **Create a branch**

```bash
git checkout -b feature/my-new-feature
```

5. **Make your changes**

```bash
# Edit files
go build -o parameterx main.go
./parameterx -d example.com -o test.txt
```

6. **Test your changes**

```bash
# Run manual tests
./parameterx -d example.com -v -o output.txt
./parameterx -s subdomains.txt -o output.txt
```

7. **Commit your changes**

```bash
git add .
git commit -m "Add feature: description of feature"
```

8. **Push to your fork**

```bash
git push origin feature/my-new-feature
```

9. **Create Pull Request**

- Go to your fork on GitHub
- Click "New Pull Request"
- Fill in the template

## Pull Request Process

### Before Submitting

- [ ] Code follows project style guidelines
- [ ] Tested on Linux/macOS
- [ ] No breaking changes (or documented if necessary)
- [ ] Updated documentation if needed
- [ ] Added examples if new feature

### PR Title Format

Use conventional commits format:

```
feat: add support for custom user agents
fix: resolve panic on empty subdomain list
docs: update installation instructions
refactor: improve URL parsing logic
test: add tests for parameter extraction
```

### PR Description Template

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Testing
How did you test this?

## Screenshots (if applicable)

## Checklist
- [ ] Code follows style guidelines
- [ ] Self-review completed
- [ ] Documentation updated
- [ ] No breaking changes
```

## Coding Standards

### Go Style Guide

Follow standard Go conventions:

```go
// Good: Clear variable names
func extractParameters(urls []string, cfg Config) {
    for _, urlStr := range urls {
        // Process URL
    }
}

// Bad: Unclear variable names
func extract(u []string, c Config) {
    for _, x := range u {
        // Process
    }
}
```

### Code Organization

```go
// 1. Package declaration
package main

// 2. Imports (grouped)
import (
    "fmt"
    "net/http"
    
    "github.com/external/package"
)

// 3. Constants
const (
    DefaultWorkers = 10
    MaxRetries     = 3
)

// 4. Types
type Config struct {
    Domain string
}

// 5. Functions
func main() {
    // ...
}
```

### Error Handling

```go
// Good: Handle errors explicitly
resp, err := http.Get(url)
if err != nil {
    fmt.Printf("[!] Request failed: %v\n", err)
    return
}
defer resp.Body.Close()

// Bad: Ignore errors
resp, _ := http.Get(url)
```

### Comments

```go
// Good: Explain why, not what
// Query multiple indexes to improve coverage of older archives
for _, index := range indexes {
    queryIndex(index)
}

// Bad: Obvious comment
// Loop through indexes
for _, index := range indexes {
    queryIndex(index)
}
```

## Testing Guidelines

### Manual Testing Checklist

Before submitting PR, test:

- [ ] Single domain: `parameterx -d example.com`
- [ ] Domain list: `parameterx -l domains.txt`
- [ ] Subdomain list: `parameterx -s subs.txt`
- [ ] Output file: `parameterx -d example.com -o output.txt`
- [ ] Verbose mode: `parameterx -d example.com -v`
- [ ] Silent mode: `parameterx -d example.com -silent`
- [ ] Custom workers: `parameterx -d example.com -w 20`
- [ ] Custom placeholder: `parameterx -d example.com -placeholder TEST`

### Test Cases

Test with various inputs:

```bash
# Valid inputs
parameterx -d example.com
parameterx -d subdomain.example.com
parameterx -s subdomains.txt

# Edge cases
parameterx -d ""  # Empty domain
parameterx -l nonexistent.txt  # Missing file
parameterx -w 0  # Invalid workers
parameterx -w 1000  # Very high workers

# Invalid inputs
parameterx  # No arguments
parameterx -d "not a domain"
parameterx -s /dev/null  # Empty file
```

## Feature Requests

### High Priority Features

Looking for contributors to work on:

1. **JSON output format**
   - Add `-json` flag
   - Output structured JSON

2. **Rate limiting**
   - Add `-delay` flag
   - Respect API rate limits

3. **Progress bar**
   - Show scan progress
   - ETA calculation

4. **Resume capability**
   - Save state
   - Resume interrupted scans

5. **More archive sources**
   - VirusTotal
   - AlienVault OTX
   - URLScan.io

## Community

### Communication Channels

- **GitHub Issues** - Bug reports and feature requests
- **Pull Requests** - Code contributions
- **Discussions** - General questions and ideas

### Recognition

Contributors will be:
- Added to CONTRIBUTORS.md
- Mentioned in release notes
- Credited in documentation

## Questions?

Feel free to:
- Open a discussion on GitHub
- Ask in pull request comments
- Tag maintainers in issues

## License

By contributing, you agree that your contributions will be licensed under the MIT License.

---

Thank you for contributing to ParameterX! 🚀

**Made with ❤️ by the ParameterX community**
