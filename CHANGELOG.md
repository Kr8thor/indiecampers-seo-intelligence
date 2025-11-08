# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.2.0] - 2025-11-08

### Added
- **Documentation:**
  - Architecture diagrams with Mermaid (docs/ARCHITECTURE.md)
  - Comprehensive FAQ with 40+ Q&As (docs/FAQ.md)
  - Cost monitoring guide with SQL queries (docs/COST_MONITORING.md)
  - Workflows README explaining each workflow (workflows/README.md)

- **Developer Experience:**
  - GitHub issue templates (bug report, feature request)
  - Issue template configuration with helpful links
  - README badges (license, tests, status)
  - Improved README table of contents

- **Project Infrastructure:**
  - Complete .gitignore with VS Code settings
  - .env.example for environment variables
  - Security documentation (SECURITY.md)
  - Repository privacy documentation (REPOSITORY_PRIVACY.md)
  - Workflow validation script (scripts/validate-workflow.js)
  - Development setup script (scripts/setup-dev.sh)
  - Integration test suite with 12 tests (tests/integration-test.js)
  - VS Code workspace settings and extensions
  - GitHub Actions CI/CD pipeline
  - CONTRIBUTING.md with detailed guidelines
  - LICENSE (MIT)
  - package.json with npm scripts

### Fixed
- JSON syntax errors in seo-intelligence-pipeline.json
- GitHub Actions workflow robustness
- Integration test for Jaccard similarity calculation

### Changed
- README structure with organized sections
- Enhanced table of contents with new documentation links

## [1.1.0] - 2025-11-08

### Added
- Comprehensive project improvement recommendations document
- Supabase integration with complete schema (6 tables, 4 views)
- Authority Collector workflow for daily metrics tracking
- Setup guide for Authority Collector with step-by-step instructions
- Supabase schema with triggers and auto-update functionality
- Cost tracking in database
- Health metrics views for easy querying

### Fixed
- Invalid JSON syntax in COMPLETE workflow
- Schema documentation inconsistencies

### Changed
- Improved documentation structure
- Enhanced setup guides with more detail

## [1.0.0] - 2025-10-26

### Added
- Initial release of IndieCampers SEO Intelligence Pipeline
- Core SEO intelligence workflow (42 nodes)
- Google Sheets integration for data storage
- Multi-market support (PT, ES, FR, DE, UK)
- Device-specific analysis (desktop + mobile)
- DataForSEO API integration (Labs, SERP, Backlinks, Rank Tracker)
- Competitor discovery and analysis
- Keyword gap analysis with opportunity scoring
- Keyword clustering algorithm
- Content brief generation
- Slack alerts for ranking changes
- Rate limit handling with exponential backoff
- Comprehensive documentation:
  - README.md with architecture overview
  - SETUP.md with credential configuration
  - TESTING.md with validation procedures
  - GOOGLE_SHEETS_SCHEMAS.md with data schemas
  - ALERTS.md with monitoring examples

### Features
- **Opportunity Scoring Algorithm:**
  - Multi-factor scoring (volume, CTR, SERP features, difficulty, intent)
  - Competitor strength penalty
  - Normalized scoring (0-100)

- **Keyword Clustering:**
  - String similarity analysis (Jaccard/token set ratio)
  - SERP overlap detection
  - Search intent classification

- **Monitoring:**
  - Daily automatic execution (07:00 UTC)
  - Anomaly detection for ranking changes
  - Cost tracking per run

### Documentation
- Complete setup guide with prerequisites
- API credential configuration instructions
- Google Sheets schema definitions
- Testing and validation procedures
- Troubleshooting common issues
- Cost estimation and optimization tips

---

## Release Notes Format

### Types of Changes
- **Added** - New features
- **Changed** - Changes in existing functionality
- **Deprecated** - Soon-to-be removed features
- **Removed** - Removed features
- **Fixed** - Bug fixes
- **Security** - Security improvements

### Version Numbering
- **Major** (x.0.0) - Breaking changes
- **Minor** (0.x.0) - New features, backward compatible
- **Patch** (0.0.x) - Bug fixes, backward compatible

---

## Upgrade Guide

### From 1.0.0 to 1.1.0

**No breaking changes.** This is a backward-compatible release.

**New features available:**
- Supabase integration (optional upgrade from Google Sheets)
- Authority Collector workflow (lightweight daily metrics)

**To use Supabase integration:**
1. Follow `docs/SETUP_AUTHORITY_COLLECTOR.md`
2. Run schema: `config/supabase_schema.sql`
3. Import workflow: `workflows/Authority_Collector_Supabase.json`

**To stay with Google Sheets:**
- No action needed
- Continue using existing workflows

---

## Future Roadmap

### Planned for 1.2.0
- [ ] Enhanced caching strategy for API cost reduction
- [ ] Dashboard templates for Supabase data visualization
- [ ] Additional SERP features analysis
- [ ] Batch processing optimization

### Planned for 1.3.0
- [ ] Technical SEO audit integration
- [ ] Page speed monitoring
- [ ] Core Web Vitals tracking
- [ ] Automated content quality scoring

### Planned for 2.0.0
- [ ] Complete rewrite with modular workflows
- [ ] Plugin system for custom integrations
- [ ] Multi-tenant support
- [ ] Advanced ML-based opportunity detection

---

**Maintained By:** IndieCampers SEO Intelligence Team
**Last Updated:** November 8, 2025
