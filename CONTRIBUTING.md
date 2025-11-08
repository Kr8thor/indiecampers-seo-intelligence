# Contributing to IndieCampers SEO Intelligence

Thank you for your interest in contributing! This document provides guidelines for contributing to this project.

## Table of Contents

- [Getting Started](#getting-started)
- [Development Guidelines](#development-guidelines)
- [Submitting Changes](#submitting-changes)
- [Pull Request Guidelines](#pull-request-guidelines)
- [Reporting Bugs](#reporting-bugs)
- [Feature Requests](#feature-requests)
- [Code of Conduct](#code-of-conduct)

---

## Getting Started

### Prerequisites

- Node.js 18+ installed
- Git installed
- n8n account (cloud or self-hosted)
- Basic understanding of n8n workflows
- Familiarity with SEO concepts

### Fork and Clone

1. **Fork the repository** on GitHub
2. **Clone your fork:**
   ```bash
   git clone https://github.com/YOUR-USERNAME/indiecampers-seo-intelligence.git
   cd indiecampers-seo-intelligence
   ```

3. **Create a branch:**
   ```bash
   git checkout -b feature/your-feature-name
   ```

4. **Run setup script:**
   ```bash
   ./scripts/setup-dev.sh
   ```

---

## Development Guidelines

### Code Style

**Workflow Nodes:**
- Use clear, descriptive node names
- Add descriptions to all nodes
- Keep nodes focused (single responsibility)
- Group related nodes visually

**JavaScript Code:**
- Use ES6+ syntax
- Add comments for complex logic
- Use meaningful variable names
- Handle errors gracefully

**Example:**
```javascript
// ✅ Good
const opportunityScore = calculateScore({
  volume: keyword.search_volume,
  difficulty: keyword.keyword_difficulty,
  clickPotential: keyword.ctr_estimate
});

// ❌ Bad
const s = calc(kw.vol, kw.diff, kw.ctr);
```

### Documentation

**When adding features:**
- Update README.md if it's a major feature
- Add examples to relevant docs
- Update CHANGELOG.md
- Add comments in workflow nodes

**Documentation standards:**
- Use clear, concise language
- Include code examples
- Add screenshots for UI changes
- Keep setup guides current

### Testing

**Before submitting:**
```bash
# Validate workflow JSON
node scripts/validate-workflow.js workflows/your-workflow.json

# Run tests
npm test

# Validate all workflows
npm run validate:all
```

**Test checklist:**
- [ ] Workflow executes without errors
- [ ] No hardcoded credentials
- [ ] Data validation passes
- [ ] No duplicate entries
- [ ] Cost estimate documented

---

## Submitting Changes

### Commit Message Format

Use clear, descriptive commit messages following this format:

```
<type>: <description>

[optional body]

[optional footer]
```

**Types:**
- `feat:` - New feature
- `fix:` - Bug fix
- `docs:` - Documentation changes
- `perf:` - Performance improvement
- `refactor:` - Code refactoring (no functional changes)
- `test:` - Adding or updating tests
- `chore:` - Maintenance tasks (dependencies, etc.)

**Examples:**
```bash
git commit -m "feat: add caching for backlink data"
git commit -m "fix: correct OpportunityScore calculation for high-volume keywords"
git commit -m "docs: update Supabase setup guide with troubleshooting section"
git commit -m "perf: optimize competitor loop with parallel processing"
```

### Push Changes

```bash
git push origin feature/your-feature-name
```

### Create Pull Request

1. Go to GitHub repository
2. Click "New Pull Request"
3. Select your branch
4. Fill in PR template (see below)
5. Submit for review

---

## Pull Request Guidelines

### PR Title Format

```
<type>: <description>

Examples:
feat: Add keyword clustering algorithm
fix: Resolve duplicate entries in Competitors tab
docs: Add FAQ documentation
perf: Reduce API calls with caching
```

### PR Description Template

```markdown
## Description
Brief description of what this PR does and why.

## Changes Made
- Change 1: Added keyword clustering
- Change 2: Updated opportunity scoring
- Change 3: Fixed duplicate detection

## Type of Change
- [ ] Bug fix (non-breaking change which fixes an issue)
- [ ] New feature (non-breaking change which adds functionality)
- [ ] Breaking change (fix or feature that would cause existing functionality to not work as expected)
- [ ] Documentation update

## Testing
- [ ] Tested locally with dry run (1 market, desktop)
- [ ] Validated workflow JSON syntax
- [ ] No credentials committed
- [ ] Updated documentation
- [ ] Added/updated tests

## Screenshots (if applicable)
[Add screenshots of workflow changes or output]

## Breaking Changes
[List any breaking changes, or write "None"]

## Cost Impact
- Estimated cost change: [e.g., "+$2/run" or "No change" or "-15% API calls"]
- Reasoning: [Brief explanation]

## Checklist
- [ ] Code follows project style guidelines
- [ ] Self-review completed
- [ ] Comments added for complex logic
- [ ] Documentation updated
- [ ] No new warnings generated
- [ ] Tests pass locally
```

### Review Process

1. **Automated checks** run on all PRs
2. **Maintainer reviews** code and tests
3. **Feedback** provided if changes needed
4. **Merge** once approved

**Review criteria:**
- Code quality and style
- Functionality correctness
- Documentation completeness
- Test coverage
- No security issues

---

## Reporting Bugs

### Before Reporting

1. **Search existing issues** to avoid duplicates
2. **Test with latest version** to ensure bug still exists
3. **Gather information** about your environment

### Bug Report Template

```markdown
**Describe the bug**
A clear and concise description of what the bug is.

**To Reproduce**
Steps to reproduce the behavior:
1. Configure workflow with '...'
2. Run execution with '...'
3. Check output in '...'
4. See error

**Expected behavior**
A clear description of what you expected to happen.

**Actual behavior**
What actually happened.

**Screenshots**
If applicable, add screenshots to help explain your problem.

**Environment:**
- n8n Version: [e.g. 0.235.0]
- Workflow: [e.g. seo-intelligence-pipeline.json]
- Node.js Version: [e.g. 18.0.0]
- DataForSEO Plan: [e.g. Standard]
- Database: [e.g. Supabase / Google Sheets]

**Workflow Configuration:**
```json
{
  "MARKETS": ["PT"],
  "MAX_COMPETITORS_PER_MARKET": 10,
  // ... other relevant settings
}
```

**Error Messages:**
```
Paste any error messages here
```

**Additional context**
Add any other context about the problem here.
```

---

## Feature Requests

### Before Requesting

1. **Check existing issues/discussions**
2. **Consider if it fits project scope**
3. **Think about implementation complexity**

### Feature Request Template

```markdown
**Is your feature request related to a problem?**
A clear description of the problem. Ex. I'm always frustrated when [...]

**Describe the solution you'd like**
A clear and concise description of what you want to happen.

**Describe alternatives you've considered**
Other solutions or features you've considered.

**Use Case**
Describe the specific use case for this feature.
- Who would use it?
- How often would it be used?
- What problem does it solve?

**Implementation Ideas**
If you have ideas about how to implement this, share them here.

**Additional context**
Add any other context, screenshots, or examples.

**Estimated Complexity:**
- [ ] Low (configuration change)
- [ ] Medium (new node/modification)
- [ ] High (major workflow change)

**API Cost Impact:**
- [ ] No additional API calls
- [ ] Minimal cost increase
- [ ] Significant cost increase (needs optimization)
```

---

## Development Workflow

### Typical Workflow

1. **Create issue** describing feature/bug
2. **Get approval** from maintainer (for major features)
3. **Create branch** from main
4. **Implement changes** with tests
5. **Validate** with validation script
6. **Update docs** as needed
7. **Submit PR** with clear description
8. **Address review** feedback
9. **Merge** when approved

### Branch Naming

```
feature/keyword-clustering
fix/duplicate-entries
docs/setup-guide-update
perf/api-call-optimization
refactor/opportunity-scoring
```

---

## Code Review Checklist

### For Reviewers

- [ ] Code is clear and well-documented
- [ ] No hardcoded credentials
- [ ] Error handling is appropriate
- [ ] Tests cover new functionality
- [ ] Documentation is updated
- [ ] No breaking changes (or clearly documented)
- [ ] Performance impact is acceptable
- [ ] Security best practices followed

### For Contributors

**Before requesting review:**
- [ ] All tests pass
- [ ] No linting errors
- [ ] Documentation updated
- [ ] CHANGELOG.md updated
- [ ] Commits are clean and descriptive
- [ ] PR description is complete

---

## Questions?

- **General questions:** Open a GitHub Discussion
- **Bug reports:** Open a GitHub Issue
- **Feature ideas:** Open a GitHub Issue with feature request template
- **Security issues:** See SECURITY.md for reporting process
- **Urgent matters:** Tag @Kr8thor in issue/PR

---

## Recognition

Contributors will be recognized in:
- README.md contributors section
- Release notes (CHANGELOG.md)
- Project documentation

---

## Code of Conduct

### Our Pledge

We are committed to providing a welcoming and inspiring community for all.

**We pledge to:**
- Be respectful and inclusive
- Provide constructive feedback
- Focus on what is best for the community
- Show empathy towards others

**Unacceptable behavior includes:**
- Harassment or discrimination
- Trolling or insulting comments
- Personal or political attacks
- Publishing others' private information

### Enforcement

Instances of unacceptable behavior may be reported to project maintainers.
All complaints will be reviewed and investigated promptly and fairly.

---

## License

By contributing, you agree that your contributions will be licensed under the MIT License.

---

## Thank You!

Your contributions make this project better for everyone. We appreciate your time and effort! 🎉

**Happy Contributing!**

---

**Last Updated:** November 8, 2025
**Version:** 1.0
