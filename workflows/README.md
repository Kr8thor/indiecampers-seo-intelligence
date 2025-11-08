# Workflows Directory

This directory contains n8n workflow JSON files for the IndieCampers SEO Intelligence system.

## Available Workflows

### 1. seo-intelligence-pipeline.json
**Purpose:** Core SEO intelligence workflow with Google Sheets storage
**Use Case:** Main production workflow for comprehensive SEO analysis
**Prerequisites:**
- DataForSEO API account
- Google Sheets API access
- n8n instance (cloud or self-hosted)

**Features:**
- Multi-market support (PT, ES, FR, DE, UK)
- Device-specific analysis (desktop + mobile)
- Competitor discovery and analysis
- Keyword gap analysis with opportunity scoring
- Keyword clustering
- Content brief generation
- Slack alerts for ranking changes

**Cost:** ~$15-20 per run (5 markets, 2 devices)
**Execution Time:** 30-45 minutes
**Nodes:** 42

---

### 2. COMPLETE-seo-intelligence-pipeline.json
**Purpose:** Extended version with all features enabled
**Use Case:** Full feature set including advanced monitoring and alerts
**Status:** ⚠️ Use with caution - higher API cost

**Features:** Everything in seo-intelligence-pipeline.json plus:
- Enhanced monitoring
- Additional SERP features analysis
- More comprehensive data collection

**Cost:** ~$20-30 per run
**Execution Time:** 45-60 minutes
**Nodes:** 50+

**Note:** Best for comprehensive analysis when cost is not a constraint.

---

### 3. Authority_Collector_Supabase.json
**Purpose:** Daily metrics collection with Supabase database storage
**Use Case:** Lightweight, database-backed metrics tracking
**Prerequisites:**
- DataForSEO API account
- Supabase account (free tier sufficient)
- n8n instance

**Features:**
- Daily domain authority tracking
- Keyword ranking metrics
- Backlink monitoring
- Cost tracking in database
- Anomaly detection with alerts
- Historical trend analysis

**Cost:** ~$0.60 per run (5 markets)
**Execution Time:** 60-90 seconds
**Nodes:** 14

**Advantages:**
- 97% cheaper than full pipeline
- Faster execution
- Better for daily monitoring
- Scalable database storage
- Easy querying with SQL

**Recommended for:** Regular monitoring with periodic full analysis

---

### 4. DEMONSTRATION-workflow.json
**Purpose:** Quick demo/testing workflow
**Use Case:** Learning the workflow structure, testing setup
**Prerequisites:** Minimal - can run with limited API credits

**Features:**
- Simplified version of main workflow
- Limited API calls
- Clear node organization
- Well-commented

**Cost:** Minimal (< $1)
**Execution Time:** 5-10 minutes
**Nodes:** ~20

**Recommended for:** New users getting started

---

## Which Workflow Should I Use?

### Decision Tree

```
Start Here
    |
    ├─ First time user?
    |       └─ Yes → Use DEMONSTRATION-workflow.json
    |
    ├─ Need daily monitoring?
    |       └─ Yes → Use Authority_Collector_Supabase.json
    |
    ├─ Want database storage?
    |       └─ Yes → Use Authority_Collector_Supabase.json
    |
    ├─ Need comprehensive analysis?
    |       └─ Yes → Use seo-intelligence-pipeline.json
    |
    └─ Need all features regardless of cost?
            └─ Yes → Use COMPLETE-seo-intelligence-pipeline.json
```

### Recommended Combinations

**Best Practice Approach:**
1. **Daily:** Authority_Collector_Supabase.json (track trends)
2. **Weekly:** seo-intelligence-pipeline.json (full analysis)
3. **Monthly:** COMPLETE-seo-intelligence-pipeline.json (deep dive)

**Budget-Conscious:**
1. **Daily:** Authority_Collector_Supabase.json
2. **Monthly:** seo-intelligence-pipeline.json

**Get-Started:**
1. **Once:** DEMONSTRATION-workflow.json (learning)
2. **Then:** Authority_Collector_Supabase.json (production)

---

## Workflow Comparison

| Feature | Demonstration | Pipeline | Complete | Authority Collector |
|---------|--------------|----------|----------|-------------------|
| **Cost/Run** | < $1 | $15-20 | $20-30 | $0.60 |
| **Duration** | 5-10 min | 30-45 min | 45-60 min | 60-90 sec |
| **Markets** | 1 | 5 | 5 | 5 |
| **Devices** | 1 | 2 | 2 | 1 |
| **Storage** | Sheets | Sheets | Sheets | Supabase |
| **Competitors** | 5 | 20 | 30 | N/A |
| **Keywords** | 200 | 1000 | 2000 | N/A |
| **Gap Analysis** | ✅ | ✅ | ✅ | ❌ |
| **Clustering** | ❌ | ✅ | ✅ | ❌ |
| **Content Briefs** | ❌ | ✅ | ✅ | ❌ |
| **Alerts** | ❌ | ✅ | ✅ | ✅ |
| **Metrics Tracking** | ❌ | ❌ | ❌ | ✅ |
| **Best For** | Learning | Weekly | Monthly | Daily |

---

## Installation Guide

### General Steps (All Workflows)

1. **Import to n8n:**
   ```
   Workflows → Add Workflow → Import from File → Select JSON
   ```

2. **Configure credentials:**
   - DataForSEO API (required for all)
   - Google Sheets API (for pipeline workflows)
   - Supabase (for Authority Collector)
   - Slack Webhook (optional, for alerts)

3. **Update settings:**
   - Edit "Global Settings" node (if present)
   - Set your target domain
   - Adjust markets/devices as needed
   - Configure thresholds

4. **Test run:**
   - Click "Execute Workflow"
   - Monitor execution
   - Verify output data

5. **Activate schedule:**
   - Enable "Schedule Trigger" node
   - Set desired frequency
   - Toggle workflow to "Active"

### Specific Setup Guides

- **Authority Collector:** See `docs/SETUP_AUTHORITY_COLLECTOR.md`
- **Pipeline Workflows:** See `docs/SETUP.md`
- **General Setup:** See `docs/QUICK_START.md`

---

## Workflow Maintenance

### Regular Tasks

**Weekly:**
- Review execution logs in n8n
- Check for errors or warnings
- Verify data quality

**Monthly:**
- Review API costs vs. budget
- Update competitor lists if needed
- Adjust thresholds based on results

**Quarterly:**
- Rotate API credentials (see SECURITY.md)
- Update to latest workflow versions
- Review and optimize settings

### Updating Workflows

**To update an existing workflow:**

1. **Export current version:**
   ```
   Workflow → Settings → Download
   ```

2. **Backup data** (if using Google Sheets)

3. **Import new version:**
   ```
   Import from File → Select new JSON
   ```

4. **Reconfigure credentials:**
   - Credentials don't transfer automatically
   - Reassign to each node

5. **Test before production:**
   - Run dry run with 1 market
   - Verify output matches expectations

---

## Troubleshooting

### Common Issues

**Issue: "Workflow fails on DataForSEO node"**
- Solution: Check API credentials
- Verify API credits available
- Check rate limit hasn't been exceeded

**Issue: "No data in output"**
- Solution: Check target domain has rankings
- Verify market/location codes correct
- Lower rank threshold to see more data

**Issue: "Execution timeout"**
- Solution: Reduce markets or competitors
- Split into multiple workflows
- Increase n8n timeout setting

**Issue: "Duplicate entries in database/sheets"**
- Solution: Check deduplication logic
- Verify unique key constraints
- Clear and re-run if needed

### Getting Help

1. **Check documentation:** `docs/TESTING.md`, `docs/TROUBLESHOOTING.md`
2. **Review execution logs:** n8n → Executions tab
3. **Open GitHub issue:** Include workflow name, error message, environment
4. **Community:** n8n community forum

---

## Customization

### Common Customizations

**Change markets:**
```javascript
// In Global Settings node
MARKETS: [
  {"country":"PT", "language":"pt-PT", "location":"Lisbon", "location_code":2620},
  // Add your markets here
]
```

**Adjust competitor count:**
```javascript
MAX_COMPETITORS_PER_MARKET: 10  // Reduce from 20 to save cost
```

**Change opportunity score weights:**
```javascript
WEIGHTS: {
  w1_volume: 0.35,          // Increase for volume focus
  w2_click_potential: 0.25,
  w3_serp_features: 0.15,
  // ... adjust as needed
}
```

**Change schedule:**
```
Edit "Schedule Trigger" node:
- Daily at 08:00 UTC: 0 8 * * *
- Twice daily: 0 8,20 * * *
- Weekly Monday: 0 8 * * 1
```

---

## Cost Optimization Tips

### Reduce API Costs

1. **Use Authority Collector for daily** - 97% cheaper
2. **Reduce markets** - Focus on most important
3. **Lower competitor count** - 20 → 10 saves 50%
4. **Decrease keyword limit** - 1000 → 500 saves 40%
5. **Run less frequently** - Daily → weekly saves 85%
6. **Use caching** - Store backlink data for reuse

### Cost Examples

**Conservative Setup:**
- Authority Collector daily: $18/month
- Full pipeline weekly: $60/month
- **Total: $78/month**

**Aggressive Setup:**
- Full pipeline daily: $600/month
- Complete workflow daily: $900/month
- **Total: $1,500/month**

**Recommended Setup:**
- Authority Collector daily: $18/month
- Pipeline weekly: $60/month
- Complete monthly: $30/month
- **Total: $108/month**

---

## Version History

- **v1.1.0** - Added Authority Collector, Supabase integration
- **v1.0.0** - Initial release with pipeline workflows

---

**Need Help?**
- Documentation: `docs/` directory
- Issues: GitHub Issues
- Community: n8n Community Forum

**Last Updated:** November 8, 2025
