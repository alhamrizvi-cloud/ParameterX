# Security Policy

## Supported Versions

We release patches for security vulnerabilities in the following versions:

| Version | Supported          |
| ------- | ------------------ |
| 1.0.x   | :white_check_mark: |
| < 1.0   | :x:                |

## Reporting a Vulnerability

The ParameterX team takes security bugs seriously. We appreciate your efforts to responsibly disclose your findings.

### How to Report

**Please DO NOT report security vulnerabilities through public GitHub issues.**

Instead, please report them via:

1. **GitHub Security Advisory**
   - Go to the [Security tab](https://github.com/alhamrizvi-cloud/ParameterX/security)
   - Click "Report a vulnerability"
   - Fill in the details

2. **Email** (if GitHub Security Advisory is not available)
   - Send details to: security@example.com (replace with actual email)
   - Include "ParameterX Security" in the subject line

### What to Include

Please include the following information:

- Type of vulnerability
- Full paths of source file(s) related to the vulnerability
- Location of the affected source code (tag/branch/commit)
- Step-by-step instructions to reproduce the issue
- Proof-of-concept or exploit code (if possible)
- Impact of the issue
- How you discovered it

### Response Timeline

- **Initial Response**: Within 48 hours
- **Status Update**: Within 7 days
- **Fix Timeline**: Depends on severity
  - Critical: 1-7 days
  - High: 7-30 days
  - Medium: 30-90 days
  - Low: Best effort

## Security Best Practices

### For Users

When using ParameterX:

1. **Keep Updated**
   ```bash
   # Check for updates regularly
   go install github.com/alhamrizvi-cloud/ParameterX@latest
   ```

2. **Validate Input**
   - Always validate domain lists
   - Be cautious with untrusted input files
   - Review output before using in production

3. **Rate Limiting**
   - Don't abuse archive APIs
   - Use reasonable worker counts
   - Respect API terms of service

4. **Output Security**
   - Don't commit sensitive outputs to public repos
   - Be careful with parameter data containing tokens/keys
   - Review results before sharing

5. **Network Security**
   - Use on trusted networks
   - Be aware of data sent to archive APIs
   - Consider proxy usage for sensitive research

### For Developers

When contributing to ParameterX:

1. **Code Review**
   - All PRs require review
   - Security-sensitive changes need extra scrutiny
   - Use static analysis tools

2. **Dependency Management**
   - Keep Go version updated
   - Avoid unnecessary external dependencies
   - Audit any new dependencies

3. **Input Validation**
   ```go
   // Always validate user input
   if domain == "" {
       return errors.New("invalid domain")
   }
   ```

4. **Error Handling**
   ```go
   // Don't expose sensitive info in errors
   if err != nil {
       log.Printf("Operation failed: %v", err)
       return fmt.Errorf("operation failed")
   }
   ```

5. **Safe Concurrency**
   ```go
   // Use mutexes for shared data
   mu.Lock()
   defer mu.Unlock()
   // Access shared data
   ```

## Known Security Considerations

### Information Disclosure

ParameterX queries public archives. Be aware:

- Queries to archive APIs are logged by those services
- Domain names you query become part of your search history
- Results may contain sensitive historical data

**Mitigation**: Use with awareness of what data you're requesting.

### Archive API Abuse

Excessive requests can:
- Result in rate limiting
- Potentially violate terms of service
- Impact service availability

**Mitigation**: Use reasonable worker counts and delays.

### Output Data Sensitivity

Results may contain:
- Historical API keys or tokens
- Debug parameters with sensitive info
- Internal system paths

**Mitigation**: Review and sanitize output before sharing.

## Vulnerability Disclosure Policy

### Responsible Disclosure

We follow coordinated vulnerability disclosure:

1. **Report** - Researcher reports vulnerability privately
2. **Acknowledge** - We acknowledge within 48 hours
3. **Investigate** - We investigate and develop fix
4. **Fix** - We release patched version
5. **Disclose** - We publicly disclose after fix (with credit)

### Public Disclosure Timeline

- **Critical**: 7-14 days after fix
- **High**: 30 days after fix
- **Medium/Low**: 90 days after fix

### Recognition

Security researchers who responsibly disclose vulnerabilities will be:
- Credited in release notes (if desired)
- Added to SECURITY.md acknowledgments
- Thanked in GitHub Security Advisory

## Security Hall of Fame

We'd like to thank the following researchers for their contributions:

<!-- This section will be updated as security reports are received -->

*No reports yet - be the first!*

## Security Checklist

### Before Release

- [ ] Code reviewed for security issues
- [ ] Dependencies updated
- [ ] Input validation tested
- [ ] Error handling verified
- [ ] Concurrency safety checked
- [ ] Documentation reviewed
- [ ] Example outputs sanitized

### Regular Audits

We perform regular security audits:
- Monthly dependency checks
- Quarterly code reviews
- Annual penetration testing

## Contact

For security-related questions that aren't vulnerabilities:
- Open a GitHub Discussion
- Use the tag `security-question`

For urgent security issues:
- Use GitHub Security Advisory
- Or email: security@example.com

## Legal

### Safe Harbor

We support safe harbor for security researchers who:
- Make good faith effort to avoid privacy violations
- Avoid disrupting services
- Follow responsible disclosure
- Comply with applicable laws

### Scope

**In Scope:**
- ParameterX source code
- Official release binaries
- Documentation security issues
- Related infrastructure

**Out of Scope:**
- Third-party archives (Wayback, Common Crawl)
- Social engineering
- Physical attacks
- Denial of Service

## Additional Resources

- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [CWE Top 25](https://cwe.mitre.org/top25/)
- [Go Security Best Practices](https://github.com/OWASP/Go-SCP)

---

**Last Updated**: January 21, 2026

Thank you for helping keep ParameterX and its users safe!

**Made with ❤️ by Ilham Rizvi**
