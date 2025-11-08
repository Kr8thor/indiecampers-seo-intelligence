# Frequently Asked Questions (FAQ)

Common questions and answers about the IndieCampers SEO Intelligence system.

---

## Table of Contents

- [Getting Started](#getting-started)
- [Configuration](#configuration)
- [Costs & Billing](#costs--billing)
- [Data & Results](#data--results)
- [Troubleshooting](#troubleshooting)
- [Performance & Optimization](#performance--optimization)
- [Security & Privacy](#security--privacy)
- [Advanced Topics](#advanced-topics)

---

## Getting Started

### Q: Which workflow should I start with?

**A:** It depends on your needs:

**For learning:** Start with `DEMONSTRATION-workflow.json`
- Cost: < $1
- Duration: 5-10 minutes
- Perfect for understanding the system

**For daily monitoring:** Use `Authority_Collector_Supabase.json`
- Cost: ~$0.60/run
- Duration: 60-90 seconds
- Tracks key metrics over time

**For comprehensive analysis:** Use `seo-intelligence-pipeline.json`
- Cost: ~$15-20/run
- Duration: 30-45 minutes
- Full competitor analysis and content briefs

### Q: Do I need coding skills to use this?

**A:** Minimal coding knowledge required:

**To use existing workflows:**
- ✅ No coding needed
- Just configure settings in n8n UI
- Follow setup guides

**To customize workflows:**
- Basic JavaScript helpful
- SQL knowledge useful for Supabase queries
- n8n provides visual workflow editor

### Q: How long does setup take?

**A:**

| Component | Time Required |
|-----------|--------------|
| Supabase setup | 15-20 minutes |
| DataForSEO account | 5 minutes |
| n8n setup (cloud) | 10 minutes |
| Import workflow | 5 minutes |
| Configure credentials | 10 minutes |
| First test run | 10 minutes |
| **Total** | **55-70 minutes** |

Follow: `docs/SETUP_AUTHORITY_COLLECTOR.md` for step-by-step guide

---

## Configuration

### Q: How do I change which markets to analyze?

**A:** Edit the `Global Settings` node or Supabase `markets` table:

**For Google Sheets workflows:**
```javascript
MARKETS: [
  {"country":"PT", "language":"pt-PT", "location":"Lisbon", "location_code":2620},
  {"country":"ES", "language":"es-ES", "location":"Madrid", "location_code":2724}
  // Add or remove markets as needed
]
```

**For Supabase workflows:**
```sql
-- Disable a market
UPDATE markets SET active = false WHERE code = 'FR';

-- Enable a market
UPDATE markets SET active = true WHERE code = 'FR';

-- Add new market
INSERT INTO markets (code, name, location_code, language_name, domain)
VALUES ('IT', 'Italy', 2380, 'Italian', 'indiecampers.it');
```

### Q: How do I adjust the schedule?

**A:** Edit the `Schedule Trigger` node:

**Daily at 8 AM:**
```
0 8 * * *
```

**Twice daily (8 AM and 8 PM):**
```
0 8,20 * * *
```

**Weekly on Monday at 8 AM:**
```
0 8 * * 1
```

**Use:** https://crontab.guru to create custom schedules

### Q: Can I analyze multiple domains?

**A:** Yes, but requires workflow modifications:

**Option 1:** Duplicate the workflow
- Import workflow again
- Change `TARGET_DOMAIN` setting
- Run as separate workflow

**Option 2:** Modify to loop through domains
- Add domain list to settings
- Wrap main logic in domain loop
- Store results with domain identifier

### Q: Where do I find DataForSEO location codes?

**A:** https://dataforseo.com/apis/serp-api/google/locations

Common codes:
- Portugal/Lisbon: 2620
- Spain/Madrid: 2724
- France/Paris: 2250
- Germany/Berlin: 2276
- UK/London: 2826

---

## Costs & Billing

### Q: How much does this cost to run?

**A:** Costs breakdown:

**Fixed costs (monthly):**
- n8n Cloud: $20-50 (or $0 if self-hosted)
- Supabase: $0 (free tier sufficient)
- DataForSEO: $0 base fee

**Variable costs (per execution):**
- Authority Collector: ~$0.60/run
- Full Pipeline (5 markets): ~$15-20/run
- Full Pipeline (1 market): ~$3-4/run

**Monthly totals (example):**
- Daily Authority Collector: ~$18/month
- Weekly Full Pipeline: ~$60-80/month
- **Recommended combo: ~$80-100/month**

### Q: How can I reduce costs?

**A:**

**1. Reduce frequency**
```
Daily → Weekly = 85% cost reduction
```

**2. Reduce markets**
```
5 markets → 2 markets = 60% cost reduction
```

**3. Reduce competitors**
```javascript
MAX_COMPETITORS_PER_MARKET: 10  // Instead of 20
// Saves ~50% on competitor analysis
```

**4. Reduce keywords per competitor**
```javascript
TOP_KEYWORDS_PER_DOMAIN: 500  // Instead of 1000
// Saves ~40% on keyword harvesting
```

**5. Use Authority Collector for daily monitoring**
```
97% cheaper than full pipeline
Still tracks key metrics
```

### Q: What if I run out of DataForSEO credits?

**A:** Workflow will fail with error message:

**Solutions:**
1. Add credits in DataForSEO dashboard
2. Reduce scope (markets, competitors)
3. Temporarily disable workflow
4. Contact DataForSEO for credit packages

**Prevention:**
- Set up budget alerts in DataForSEO
- Monitor `api_costs` table in Supabase
- Start with small test runs

---

## Data & Results

### Q: Where is the data stored?

**A:** Depends on workflow:

**Authority Collector:**
- Supabase PostgreSQL database
- Query anytime with SQL
- Export to CSV/Excel

**Full Pipeline:**
- Google Sheets (6-8 tabs)
- Accessible via Google Drive
- Share with team members

### Q: How often is data updated?

**A:** Based on your schedule:

**Default schedules:**
- Authority Collector: Daily at 08:00 UTC
- Full Pipeline: Weekly (configure manually)

**Manual runs:**
- Click "Execute Workflow" in n8n anytime
- Useful for on-demand analysis

### Q: What does "Opportunity Score" mean?

**A:** A 0-100 score indicating keyword potential:

**Formula components:**
- Search volume (35%)
- Click potential/CTR (25%)
- SERP features (15%)
- Keyword difficulty (15%)
- Commercial intent (10%)
- Competitor strength penalty (-20%)

**Interpretation:**
- **80-100:** Excellent opportunity (prioritize)
- **60-79:** Good opportunity (consider)
- **40-59:** Moderate opportunity (secondary)
- **0-39:** Low opportunity (deprioritize)

### Q: How accurate is the data?

**A:** DataForSEO data accuracy:

**Very reliable:**
- Search volume (Google-sourced)
- Keyword difficulty
- SERP results
- Backlink counts

**Estimates:**
- Click potential (CTR estimates)
- Opportunity score (calculated)
- Commercial intent (keyword-based)

**Limitations:**
- Data is 1-7 days old (typical)
- Some keywords may have no volume data
- Seasonal fluctuations not captured

### Q: Can I export the data?

**A:**

**From Supabase:**
```sql
-- Export to CSV via dashboard
SELECT * FROM daily_metrics
WHERE date >= CURRENT_DATE - INTERVAL '30 days'
ORDER BY date DESC;

-- Or use Supabase API
```

**From Google Sheets:**
- File → Download → Excel/CSV
- Or use Google Sheets API

**From n8n:**
- Add export node to workflow
- Save to file/email/webhook

---

## Troubleshooting

### Q: Workflow execution failed, what do I do?

**A:** Check error message in n8n:

**Common errors:**

**"Permission denied" (Google Sheets)**
```
Solution: Share sheet with service account email
Settings → Sharing → Add service account
```

**"Invalid credentials" (DataForSEO)**
```
Solution: Check API credentials in n8n
Credentials → DataForSEO → Verify login/password
```

**"Rate limit exceeded"**
```
Solution: Workflow includes retry logic
Wait 5-10 minutes and try again
Or reduce scope (markets/competitors)
```

**"No data returned"**
```
Cause: Domain has no rankings in that market
Solution: Check TARGET_DOMAIN is correct
Try different market or lower rank threshold
```

### Q: No competitors found, why?

**A:** Possible reasons:

**1. Domain too new/small**
```
Solution: Lower RANK_THRESHOLD (20 → 50)
```

**2. Wrong market/location**
```
Solution: Verify location code is correct
Check domain actually operates in that market
```

**3. No keyword overlap**
```
Solution: Check if domain ranks for anything
Reduce MIN_VOL threshold temporarily
```

### Q: Tests are failing, how do I fix?

**A:**

**Run tests to see errors:**
```bash
npm test
```

**Common test failures:**

**"Cannot find module"**
```bash
npm install  # Install dependencies
```

**"Assertion failed"**
```
Check test expectations match your modifications
Update test data if you changed algorithms
```

**"JSON syntax error"**
```bash
# Validate workflow JSON
python3 -m json.tool workflows/your-file.json
```

### Q: How do I check workflow execution logs?

**A:**

**In n8n:**
1. Go to "Executions" tab
2. Click on execution
3. See node-by-node results

**In GitHub Actions:**
1. Go to Actions tab
2. Click on workflow run
3. Expand each step to see logs

**In Supabase:**
```sql
-- Check recent API calls
SELECT * FROM api_costs
ORDER BY timestamp DESC
LIMIT 100;

-- Check for errors in metrics
SELECT * FROM daily_metrics
WHERE date = CURRENT_DATE;
```

---

## Performance & Optimization

### Q: Workflow is taking too long, how to speed it up?

**A:** Optimization strategies:

**1. Reduce competitors**
```javascript
MAX_COMPETITORS_PER_MARKET: 10  // From 20
// Saves ~50% execution time
```

**2. Reduce keywords**
```javascript
TOP_KEYWORDS_PER_DOMAIN: 500  // From 1000
```

**3. Remove unused phases**
```
Comment out: Content Briefs generation
Comment out: Clustering (if not needed)
```

**4. Split into multiple workflows**
```
Workflow 1: PT + ES
Workflow 2: FR + DE
Workflow 3: UK
Run in parallel
```

**5. Use Authority Collector instead**
```
97% faster than full pipeline
Perfect for daily monitoring
```

### Q: Can I run workflows in parallel?

**A:** Yes, but carefully:

**Safe to parallel:**
- Different markets in separate workflows
- Authority Collector (different hours)
- Read-only workflows

**NOT safe to parallel:**
- Same workflow multiple times
- Writing to same Google Sheet tab
- Same DataForSEO credentials (rate limits)

**Best practice:**
- Stagger schedules by 1 hour
- Use different credentials if possible
- Monitor API rate limits

### Q: How do I monitor performance over time?

**A:**

**In Supabase:**
```sql
-- Execution duration trend
SELECT
  DATE(timestamp) as date,
  workflow_name,
  COUNT(*) as runs,
  AVG(EXTRACT(EPOCH FROM (updated_at - created_at))) as avg_duration_seconds
FROM api_costs
GROUP BY DATE(timestamp), workflow_name
ORDER BY date DESC;

-- Cost trend
SELECT
  DATE_TRUNC('month', timestamp) as month,
  SUM(cost_usd) as total_cost,
  COUNT(DISTINCT DATE(timestamp)) as days_run
FROM api_costs
GROUP BY month
ORDER BY month DESC;
```

**In n8n:**
- Executions tab shows duration
- Filter by workflow
- View success/failure rate

---

## Security & Privacy

### Q: Is my data secure?

**A:** Security measures in place:

**Credentials:**
- ✅ Stored in n8n credential vault (encrypted)
- ✅ `.env` files gitignored
- ✅ No credentials in workflow JSON

**Data:**
- ✅ Supabase uses TLS encryption
- ✅ Google Sheets access controlled
- ✅ Only public SEO data collected (no PII)

**Access:**
- ✅ Repository should be private
- ✅ n8n requires authentication
- ✅ Supabase RLS can be enabled

### Q: Is the repository public or private?

**A:** **MUST be private**

**Verify at:**
```
https://github.com/Kr8thor/indiecampers-seo-intelligence/settings
```

**Why private:**
- Contains proprietary SEO strategies
- Competitor analysis methodologies
- Business intelligence workflows

**See:** `REPOSITORY_PRIVACY.md` for complete guide

### Q: What data is collected?

**A:** Only **public SEO data**:

**Collected:**
- ✅ Keyword rankings (publicly searchable)
- ✅ Backlinks (publicly accessible)
- ✅ SERP results (public Google data)
- ✅ Domain metrics (public information)

**NOT collected:**
- ❌ Personal user data
- ❌ Email addresses
- ❌ IP addresses
- ❌ Payment information
- ❌ Private customer data

**GDPR compliant:** No personal data = no GDPR issues

### Q: Who has access to the data?

**A:**

**n8n Cloud:**
- Workflow owner (admin access)
- Team members (if added)
- n8n infrastructure (encrypted at rest)

**Supabase:**
- Project owner
- Service account (used by workflows)
- Collaborators (if added)

**Google Sheets:**
- Sheet owner
- Users you explicitly share with
- Service account email

**Best practice:**
- Limit access to necessary people only
- Use read-only access where possible
- Audit access quarterly

---

## Advanced Topics

### Q: Can I integrate with other tools?

**A:** Yes, n8n supports 300+ integrations:

**Common integrations:**
- Airtable (alternative to Google Sheets)
- Monday.com (project management)
- Notion (documentation)
- Email (alerts and reports)
- Webhooks (custom integrations)
- APIs (any REST API)

**Example: Send to Airtable**
1. Add Airtable node after data processing
2. Configure Airtable credentials
3. Map fields to Airtable columns

### Q: How do I add custom calculations?

**A:** Use "Code" nodes in n8n:

**Example: Custom opportunity score**
```javascript
const items = $input.all();

return items.map(item => ({
  json: {
    ...item.json,
    custom_score: (
      item.json.search_volume * 0.5 +
      item.json.difficulty * 0.3 +
      item.json.ctr * 0.2
    )
  }
}));
```

**Example: Custom filtering**
```javascript
const items = $input.all();

// Only keep high-volume, low-difficulty keywords
return items.filter(item =>
  item.json.search_volume > 1000 &&
  item.json.keyword_difficulty < 30
);
```

### Q: Can I add machine learning predictions?

**A:** Yes, with external APIs:

**Options:**
1. Call Python ML API from n8n
2. Use Google Cloud AI/ML APIs
3. Use OpenAI API for content analysis
4. Build custom prediction service

**Example workflow:**
```
Historical data → ML API → Predictions → Supabase
```

### Q: How do I backup my data?

**A:**

**Supabase:**
```bash
# Automatic backups (Pro plan)
# Or export manually:
```

```sql
-- Export to CSV via dashboard
SELECT * FROM daily_metrics;
```

**Google Sheets:**
- File → Make a copy
- Or use Google Takeout

**n8n Workflows:**
- Export workflow JSON
- Store in version control (Git)
- Already done in this repository

**Recommendation:**
- Export Supabase data monthly to CSV
- Keep workflow JSON in Git (already done)
- Backup Google Sheets quarterly

### Q: Can I run this locally?

**A:** Yes, for development:

**Requirements:**
- Docker or Node.js 18+
- n8n installed locally
- Local PostgreSQL (or use Supabase cloud)

**Setup:**
```bash
# Using Docker
docker run -it --rm \
  --name n8n \
  -p 5678:5678 \
  -e N8N_BASIC_AUTH_ACTIVE=true \
  -e N8N_BASIC_AUTH_USER=admin \
  -e N8N_BASIC_AUTH_PASSWORD=password \
  -v ~/.n8n:/home/node/.n8n \
  n8nio/n8n

# Access at: http://localhost:5678
```

**Then:**
1. Import workflow JSON
2. Configure credentials
3. Run manually (don't enable schedule)

### Q: How do I contribute improvements?

**A:** See `CONTRIBUTING.md`:

**Process:**
1. Fork repository
2. Create feature branch
3. Make changes
4. Test thoroughly
5. Submit pull request

**Guidelines:**
- Follow code style
- Add tests for new features
- Update documentation
- No credentials in commits

---

## Still Have Questions?

**Check these resources:**
- [Setup Guide](SETUP.md)
- [Testing Guide](TESTING.md)
- [Architecture Docs](ARCHITECTURE.md)
- [Security Policy](../SECURITY.md)

**Get help:**
- Open GitHub Issue
- Check n8n Community Forum
- Contact DataForSEO Support

---

**Last Updated:** November 8, 2025
**Version:** 1.0
