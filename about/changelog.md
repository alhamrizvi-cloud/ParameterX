# Changelog

All notable changes to ParameterX will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Planned Features
- JSON output format
- Resume capability for interrupted scans
- Progress bar with ETA
- Integration with VirusTotal API
- AlienVault OTX support
- URLScan.io integration
- Rate limiting controls
- Custom HTTP headers support

## [1.0.0] - 2026-01-21

### Added
- Initial release of ParameterX
- Wayback Machine CDX API integration
- Archive.org text format API support
- Common Crawl multiple index support
- Concurrent processing with worker pools
- Thread-safe parameter extraction
- Smart file extension filtering
- URL normalization with custom placeholders
- Support for single domain scanning (`-d`)
- Support for domain list files (`-l`)
- Support for subdomain list files (`-s`)
- Verbose mode for debugging (`-v`)
- Silent mode for automation (`-silent`)
- Custom worker configuration (`-w`)
- Custom placeholder support (`-placeholder`)
- File output option (`-o`)
- Configurable extension exclusions (`-exclude`)
- ASCII banner display
- Comprehensive error handling
- Deduplication of URLs and parameters

### Features
- **Multiple Archive Sources**: Queries 3 different APIs for maximum coverage
- **100% Passive**: No requests sent to target domains
- **High Performance**: Concurrent processing with configurable workers
- **Flexible Input**: Supports domains, domain lists, and subdomain lists
- **Smart Filtering**: Automatically excludes static files
- **Fuzzing Ready**: Normalizes parameters with FUZZ placeholder
- **Clean Output**: Deduplicated, ready-to-use results

### Documentation
- Comprehensive README with usage examples
- EXAMPLES.md with 25+ practical use cases
- CONTRIBUTING.md for contributors
- Installation script for easy setup
- MIT License

### Technical Details
- Go 1.19+ support
- Zero external dependencies (standard library only)
- Cross-platform compatibility (Linux, macOS, Windows)
- Memory-efficient URL processing
- Timeout handling for API requests
- Graceful error recovery

## Version History

### Release Notes Format

Each release includes:
- **Added**: New features
- **Changed**: Changes in existing functionality
- **Deprecated**: Soon-to-be removed features
- **Removed**: Removed features
- **Fixed**: Bug fixes
- **Security**: Security vulnerability fixes

---

## Future Roadmap

### v1.1.0 (Planned)
- [ ] JSON output format
- [ ] Rate limiting with delays
- [ ] Progress bar
- [ ] Resume interrupted scans
- [ ] Custom HTTP headers

### v1.2.0 (Planned)
- [ ] VirusTotal integration
- [ ] AlienVault OTX support
- [ ] URLScan.io integration
- [ ] GitHub search integration
- [ ] Historical diff tracking

### v1.3.0 (Planned)
- [ ] Web interface
- [ ] API server mode
- [ ] Database storage
- [ ] Scheduled scans
- [ ] Notification system

---

## Migration Guides

### Upgrading to v1.0.0

First release - no migration needed!

**Installation:**
```bash
go install github.com/alhamrizvi-cloud/ParameterX@latest
```

**Or build from source:**
```bash
git clone https://github.com/alhamrizvi-cloud/ParameterX.git
cd ParameterX
go build -o parameterx main.go
```

---

## Release Checklist

For maintainers preparing releases:

- [ ] Update version in code
- [ ] Update CHANGELOG.md
- [ ] Update README.md if needed
- [ ] Tag release in git
- [ ] Create GitHub release
- [ ] Build binaries for all platforms
- [ ] Update documentation
- [ ] Announce release

---

## Deprecation Policy

- Features marked as deprecated will be supported for at least 2 minor versions
- Breaking changes will only occur in major version updates
- Advance notice of at least 30 days for deprecations

---

## Credits

### Contributors

Thank you to all contributors who helped build ParameterX!

- [Ilham Rizvi](https://github.com/alhamrizvi-cloud) - Creator & Maintainer

Want to be listed here? [Contribute to ParameterX!](CONTRIBUTING.md)

### Inspiration

ParameterX was inspired by:
- `gau` by lc
- `waybackurls` by tomnomnom
- `waymore` by xnl-h4ck3r
- The bug bounty community

### Special Thanks

- Internet Archive team for Wayback Machine API
- Common Crawl for open web crawl data
- Go team for excellent standard library
- Bug bounty community for feedback

---

**Made with ❤️ by alham Rizvi**

[Unreleased]: https://github.com/alhamrizvi-cloud/ParameterX/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/alhamrizvi-cloud/ParameterX/releases/tag/v1.0.0
