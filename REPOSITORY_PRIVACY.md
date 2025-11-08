# Repository Privacy Checklist

## ⚠️ IMPORTANT: This Repository Contains Sensitive Business Intelligence

This repository should **ALWAYS** remain **PRIVATE** as it contains:
- Proprietary SEO strategies
- Competitor analysis workflows
- Business intelligence methodologies
- API integration patterns
- Market-specific targeting strategies

---

## How to Verify Repository is Private

### Method 1: GitHub Web Interface

1. **Go to:** https://github.com/Kr8thor/indiecampers-seo-intelligence
2. **Look for:** A "Private" badge next to the repository name (top-left)
3. **If you see "Public":** Follow instructions below to make it private

### Method 2: GitHub Settings Page

1. **Navigate to:** https://github.com/Kr8thor/indiecampers-seo-intelligence/settings
2. **Scroll to:** "Danger Zone" section at the bottom
3. **Check visibility:** Should show "Change repository visibility" with current status
4. **Current status:** Look for "This repository is currently **private**"

---

## How to Make Repository Private

### Step-by-Step Instructions

1. **Go to repository settings:**
   ```
   https://github.com/Kr8thor/indiecampers-seo-intelligence/settings
   ```

2. **Scroll down to "Danger Zone"** (bottom of page)

3. **Click "Change visibility"**

4. **Select "Make private"**

5. **Confirm by typing the repository name:**
   ```
   Kr8thor/indiecampers-seo-intelligence
   ```

6. **Click "I understand, change repository visibility"**

7. **Verify:** A "Private" badge should now appear next to the repository name

---

## Access Control Best Practices

### Who Should Have Access?

**Repository Collaborators:**
- ✅ SEO Team Lead
- ✅ Marketing Manager
- ✅ Authorized Developers
- ❌ External Contractors (unless under NDA)
- ❌ Public/Anonymous Users

### Recommended Settings

**In Repository Settings → Manage Access:**

1. **Base permissions:** No default permissions for organization members
2. **Collaborators:** Add individually with specific roles
3. **Teams:** Only add teams that need access

**Recommended Roles:**
- **Admin:** SEO Team Lead, Project Owner
- **Write:** Active developers working on workflows
- **Read:** Stakeholders who need visibility (manager, analytics team)

---

## GitHub Actions & Workflows

### Security Note

Even with private repositories, GitHub Actions logs can expose data:

**In `.github/workflows/validate.yml`:**

✅ **Current configuration is safe:**
- No secrets printed to logs
- No API keys exposed
- No sensitive data output

⚠️ **Never do this in workflows:**
```yaml
# ❌ BAD - Don't do this
- run: echo "API_KEY=${{ secrets.API_KEY }}"
- run: cat .env
- run: git log --all  # May expose commit messages with sensitive info
```

---

## Additional Privacy Measures

### 1. GitHub Security Features

Enable these in repository settings:

- ✅ **Dependency alerts:** Settings → Security → Dependabot alerts
- ✅ **Secret scanning:** Settings → Security → Secret scanning alerts
- ✅ **Code scanning:** Settings → Security → Code scanning

### 2. .gitignore Protection

The `.gitignore` file is configured to prevent commits of:
- `.env` files
- Credential files
- API keys
- Service account JSON files

**Verify it's working:**
```bash
git status
# Should NOT show .env or credentials even if they exist
```

### 3. Commit History

**Check for accidentally committed secrets:**
```bash
# Search commit history for potential secrets
git log --all --full-history --source --grep="password\|secret\|key" -i

# Search all files in history
git log -p --all | grep -i "password\|api.key\|secret"
```

**If secrets found in history:**
1. Contact GitHub Support to purge repository
2. Rotate ALL credentials immediately
3. Consider using BFG Repo-Cleaner or git-filter-repo

---

## Sharing Guidelines

### ❌ Never Share

- Repository clone URLs
- GitHub access tokens
- Deployment keys
- Workflow outputs containing data

### ✅ Safe to Share

- Documentation (after sanitizing)
- Architecture diagrams (general)
- Non-sensitive screenshots
- Anonymized results

### Sharing with External Parties

**If you must share code with contractors/partners:**

1. **Create a sanitized copy:**
   ```bash
   # Create new repo with sensitive parts removed
   git clone indiecampers-seo-intelligence sanitized-version
   cd sanitized-version

   # Remove sensitive workflows
   rm workflows/COMPLETE-*.json

   # Remove configuration examples with real data
   rm config/example-settings.json

   # Generic the README
   sed -i 's/IndieCampers/YourCompany/g' README.md
   ```

2. **Share via zip file** (not GitHub access)

3. **Require NDA** before sharing

4. **Time-limit access** if using temporary repo

---

## Repository Forks & Clones

### Forking

**Important:** When someone forks a private repo, their fork is also private by default.

**Settings → General:**
- ❌ **Disable forking** if not needed
- Path: Settings → General → "Allow forking" (uncheck)

### Clones

All team members should:

1. **Use HTTPS with tokens** (not passwords)
2. **Or use SSH keys**
3. **Never commit** local `.env` files
4. **Be aware** repository is private and confidential

---

## Compliance & Legal

### Data Protection

This repository processes:
- ✅ Public SEO data (GDPR compliant)
- ✅ Competitor public data (legally sourced)
- ❌ No personal data
- ❌ No customer PII

### Intellectual Property

All code and workflows in this repository are:
- 🔒 Proprietary to IndieCampers
- 📝 Licensed under MIT (for internal use)
- 🚫 Not for public distribution

### Third-Party Services

**External services with access to code:**
- GitHub (required, trusted)
- GitHub Actions (required, sandboxed)
- n8n Cloud (if used - ensure private instance)

**Verify third-party tools:**
- ✅ Review OAuth scopes before granting
- ✅ Use read-only access where possible
- ✅ Revoke unused integrations regularly

---

## Incident Response

### If Repository Accidentally Made Public

**Immediate actions (within 1 hour):**

1. ✅ **Make private immediately** (follow steps above)
2. ✅ **Rotate ALL credentials:**
   - DataForSEO API password
   - Supabase service role key
   - Slack webhook URLs
   - Any other API keys

3. ✅ **Notify team:**
   - Email all collaborators
   - Include timeline of exposure
   - List affected credentials

4. ✅ **Review access logs:**
   - GitHub Insights → Traffic
   - Check for unexpected clones/views
   - Review Stars/Watchers for unknown users

5. ✅ **Document incident:**
   - What happened
   - How long exposed
   - Actions taken
   - Lessons learned

**Follow-up actions (within 24 hours):**

6. ✅ **Audit codebase** for other sensitive data
7. ✅ **Review all collaborator access**
8. ✅ **Update SECURITY.md** with lessons learned
9. ✅ **Consider security training** for team

---

## Regular Audits

**Monthly:**
- [ ] Verify repository is still private
- [ ] Review collaborator list
- [ ] Check for new forks (should be none or authorized)
- [ ] Review GitHub Actions logs for anomalies

**Quarterly:**
- [ ] Audit all secrets and credentials
- [ ] Review .gitignore effectiveness
- [ ] Check commit history for accidental secrets
- [ ] Update this checklist with new best practices

---

## Emergency Contacts

**If repository is accidentally exposed:**

1. **GitHub Support:** https://support.github.com/contact
2. **Project Owner:** [Add contact info]
3. **Security Team:** [Add contact info]
4. **CEO/CTO:** [Add contact info] (for major breaches)

---

## Quick Reference

```bash
# Check current repository visibility (requires gh CLI)
gh repo view Kr8thor/indiecampers-seo-intelligence --json visibility

# Verify .gitignore is working
git status  # Should not show .env

# Check for secrets in staging area
git diff --cached | grep -i "password\|secret\|key"

# Review recent commits for secrets
git log -p -5 | grep -i "api\|password\|secret"
```

---

**Last Reviewed:** November 8, 2025
**Next Review:** December 8, 2025
**Owner:** IndieCampers SEO Team

**Status:** ⚠️ **ACTION REQUIRED - Verify repository is private immediately**
