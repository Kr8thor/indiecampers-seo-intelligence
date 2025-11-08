# Security Policy

## Credentials Management

### ❌ NEVER Do This

```javascript
// WRONG - Hardcoded credentials
const apiKey = "sk-1234567890abcdef";
const password = "mypassword123";
```

### ✅ Always Do This

```javascript
// RIGHT - Use environment variables
const apiKey = process.env.DATAFORSEO_API_KEY;
if (!apiKey) {
  throw new Error('DATAFORSEO_API_KEY environment variable not set');
}
```

---

## Environment Variables Setup

### n8n Cloud

1. Go to Settings → Environment Variables
2. Add each variable from `.env.example`
3. Use in workflows: `process.env.VARIABLE_NAME`

### Self-Hosted n8n

1. Copy `.env.example` to `.env`:
   ```bash
   cp .env.example .env
   ```

2. Edit `.env` with your actual credentials:
   ```bash
   nano .env  # or use your preferred editor
   ```

3. **NEVER commit `.env` to version control** (it's in `.gitignore`)

4. Load in n8n:
   ```bash
   # The .env file will be automatically loaded by n8n
   docker run -it --rm \
     --name n8n \
     -p 5678:5678 \
     --env-file .env \
     -v ~/.n8n:/home/node/.n8n \
     n8nio/n8n
   ```

---

## Credential Storage Best Practices

### What to Store Where

| Credential | Storage Method | Example |
|------------|----------------|---------|
| DataForSEO API | n8n Credentials Manager | Via UI or env vars |
| Supabase Service Key | n8n Credentials Manager | Via UI or env vars |
| Slack Webhook | n8n Credentials Manager | Via UI or env vars |
| Google Sheets Service Account | Upload JSON or env var | Via UI |

### n8n Credentials Manager

**Recommended approach:**

1. Go to n8n → Credentials → Add Credential
2. Select credential type (e.g., "DataForSEO API")
3. Enter credentials
4. Name it clearly (e.g., "IndieCampers DataForSEO")
5. Save

**Using environment variables in credentials:**

You can reference environment variables in n8n credentials:
```
={{$env.DATAFORSEO_LOGIN}}
={{$env.DATAFORSEO_PASSWORD}}
```

---

## Credential Rotation Schedule

**Regular rotation prevents long-term exposure if credentials are compromised.**

| Service | Rotation Frequency | Priority |
|---------|-------------------|----------|
| DataForSEO API | Every 90 days | High |
| Supabase Service Key | Every 180 days | High |
| Slack Webhook | If compromised only | Medium |
| Google Sheets Service Account | Every 365 days | Medium |

### Rotation Process

1. **Generate new credential** in service dashboard
2. **Update n8n** with new credential
3. **Test workflow** to ensure it works
4. **Revoke old credential** after confirmation
5. **Document** rotation in password manager

---

## Access Control

### Supabase Row Level Security (RLS)

**Enable RLS on all tables:**

```sql
-- Enable RLS
ALTER TABLE daily_metrics ENABLE ROW LEVEL SECURITY;
ALTER TABLE backlinks ENABLE ROW LEVEL SECURITY;
ALTER TABLE api_costs ENABLE ROW LEVEL SECURITY;

-- Policy: Only service role can write
CREATE POLICY "Service role can insert metrics"
  ON daily_metrics FOR INSERT
  TO service_role
  WITH CHECK (true);

CREATE POLICY "Service role can update metrics"
  ON daily_metrics FOR UPDATE
  TO service_role
  USING (true);

-- Read-only policy for anon key (if building dashboard)
CREATE POLICY "Public can read latest metrics"
  ON daily_metrics FOR SELECT
  TO anon
  USING (date >= CURRENT_DATE - INTERVAL '30 days');
```

### n8n Access Control

**For team deployments:**

- ✅ Use separate n8n accounts for each team member
- ✅ Enable 2FA on all accounts
- ✅ Use SSO if available (n8n Enterprise)
- ✅ Restrict workflow editing permissions
- ✅ Use IP whitelisting if possible
- ✅ Audit execution logs monthly

**Self-hosted security:**

```bash
# Enable basic authentication
N8N_BASIC_AUTH_ACTIVE=true
N8N_BASIC_AUTH_USER=admin
N8N_BASIC_AUTH_PASSWORD=strong-password-here

# Use HTTPS in production
N8N_PROTOCOL=https
N8N_SSL_KEY=/path/to/ssl/key.pem
N8N_SSL_CERT=/path/to/ssl/cert.pem
```

---

## Data Privacy & GDPR Compliance

### What Data Is Collected?

✅ **Only public SEO data:**
- Domain rankings (public information)
- Backlinks (publicly accessible)
- Keyword metrics (public search data)
- SERP results (publicly available)

❌ **No personal data:**
- No user identifiable information
- No email addresses
- No IP addresses
- No tracking cookies

### Data Retention Policy

**Recommended retention:**
- **Daily metrics:** Keep for 2 years
- **API costs:** Keep for 3 years (accounting)
- **Old backlinks:** Archive after 1 year
- **Technical audits:** Keep latest 90 days

**Automatic cleanup:**

```sql
-- Schedule this to run monthly
CREATE OR REPLACE FUNCTION cleanup_old_data()
RETURNS void AS $$
BEGIN
  -- Delete metrics older than 2 years
  DELETE FROM daily_metrics
  WHERE date < CURRENT_DATE - INTERVAL '2 years';

  -- Archive old backlinks
  UPDATE backlinks
  SET status = 'archived'
  WHERE last_checked < CURRENT_DATE - INTERVAL '1 year'
    AND status = 'active';

  -- Delete archived backlinks older than 3 years
  DELETE FROM backlinks
  WHERE status = 'archived'
    AND last_checked < CURRENT_DATE - INTERVAL '3 years';
END;
$$ LANGUAGE plpgsql;
```

### GDPR Rights

Since no personal data is collected:
- ✅ Right to access: N/A (no personal data)
- ✅ Right to deletion: N/A (no personal data)
- ✅ Right to portability: Export via Supabase
- ✅ Right to rectification: Update via Supabase

---

## Incident Response Plan

### If Credentials Are Leaked

**Immediate actions (within 1 hour):**

1. ✅ **Rotate compromised credentials immediately**
   - DataForSEO: Generate new API password
   - Supabase: Generate new service role key
   - Slack: Regenerate webhook URL

2. ✅ **Review recent activity**
   - Check n8n execution logs for unauthorized runs
   - Review Supabase logs for unusual queries
   - Check DataForSEO usage for unexpected API calls

3. ✅ **Assess impact**
   - Was data accessed or modified?
   - Were API credits consumed?
   - Were alerts sent inappropriately?

**Follow-up actions (within 24 hours):**

4. ✅ **Update team**
   - Notify all team members
   - Share new credentials securely
   - Update documentation

5. ✅ **Document incident**
   - Record what happened
   - Note how it was resolved
   - Update security procedures

6. ✅ **Strengthen security**
   - Review access controls
   - Enable additional monitoring
   - Schedule more frequent rotations

### Emergency Contacts

| Service | Support Contact | Response Time |
|---------|----------------|---------------|
| n8n | support@n8n.io | 24-48 hours |
| DataForSEO | support@dataforseo.com | 12-24 hours |
| Supabase | support@supabase.io | 24 hours |

---

## Security Checklist

### Initial Setup

- [ ] `.env` file created and populated
- [ ] `.env` added to `.gitignore`
- [ ] All credentials stored in n8n Credentials Manager
- [ ] Service account has minimum required permissions
- [ ] 2FA enabled on all accounts
- [ ] Credentials backed up in password manager

### Ongoing Maintenance

- [ ] Review execution logs monthly
- [ ] Rotate credentials per schedule
- [ ] Update dependencies quarterly
- [ ] Audit Supabase access logs
- [ ] Review API usage for anomalies
- [ ] Test credential rotation process

### Before Each Deployment

- [ ] Validate workflow JSON (no hardcoded secrets)
- [ ] Test with test credentials first
- [ ] Review recent commits for sensitive data
- [ ] Ensure `.env` not in version control
- [ ] Verify SSL/TLS enabled in production

---

## Reporting Security Issues

**Found a security vulnerability?**

Please report it responsibly:

1. **Do NOT** open a public GitHub issue
2. **Email** the maintainer directly (see README for contact)
3. **Include** detailed description and reproduction steps
4. **Wait** for response before public disclosure

We aim to respond within 48 hours and resolve critical issues within 7 days.

---

## Additional Resources

- [n8n Security Best Practices](https://docs.n8n.io/hosting/security/)
- [Supabase Security Guide](https://supabase.com/docs/guides/platform/security)
- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [DataForSEO API Security](https://dataforseo.com/apis/authentication)

---

**Last Updated:** November 8, 2025
**Version:** 1.0
