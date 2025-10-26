# Quick Start Guide

## Prerequisites

- n8n account (Cloud or Self-hosted)
- DataForSEO API credentials
- Supabase account (free tier)
- Slack webhook (optional, for alerts)

## Setup in 15 Minutes

### Step 1: Supabase Setup (5 minutes)

1. **Create Project**
   - Go to https://supabase.com
   - Click "New Project"
   - Choose region: Europe
   - Wait 2 minutes for provisioning

2. **Run Schema**
   - Open SQL Editor
   - Copy `config/supabase_schema.sql`
   - Click "Run"
   - Verify: Check "Table Editor" for 3 tables

3. **Get Credentials**
   - Settings → API
   - Copy: Project URL + Service Role Key

### Step 2: n8n Setup (5 minutes)

1. **Add Credentials**
   ```
   n8n → Credentials → Add:
   - Supabase (URL + Service Role Key)
   - DataForSEO (Login + Password)
   - Slack (Webhook URL - optional)
   ```

2. **Import Workflow**
   - Workflows → Import from File
   - Select `workflows/Authority_Collector_Supabase.json`
   - Update all credential references

### Step 3: Test Run (5 minutes)

1. **Manual Test**
   - Open workflow
   - Click "Execute Workflow"
   - Check execution log

2. **Verify Data**
   ```sql
   -- In Supabase SQL Editor
   SELECT * FROM latest_metrics;
   ```

3. **Schedule**
   - Activate workflow (toggle in top-right)
   - Runs daily at 08:00 UTC

## What Happens Next?

### Day 1
- First metrics collected
- Baseline established

### Day 7
- 7-day trends available
- Anomaly detection active

### Day 30
- Monthly reports ready
- Full trend analysis

## Key Queries

```sql
-- Latest metrics
SELECT * FROM latest_metrics;

-- 7-day trend
SELECT 
  code,
  date,
  domain_rating,
  average_ranking
FROM daily_metrics
WHERE date >= CURRENT_DATE - INTERVAL '7 days'
ORDER BY code, date DESC;

-- Total API costs
SELECT 
  SUM(cost_usd) as total_spent
FROM api_costs;
```

## Troubleshooting

### Workflow Fails
- Check DataForSEO credits
- Verify Supabase credentials
- Check execution logs

### No Data in Supabase
- Verify markets table has 5 rows
- Check workflow execution log
- Test Supabase connection

### Alerts Not Sending
- Verify Slack webhook URL
- Check "If Anomalies Detected" node
- Test with manual anomaly

## Next Steps

1. ✅ Review `docs/README_SUPABASE_INTEGRATION.md` for details
2. ✅ Check `docs/TESTING.md` for validation tests
3. ✅ Read `docs/ALERTS.md` for alert configuration

## Support

- **Issues?** Check GitHub Issues
- **Questions?** Open Discussion
- **Bugs?** Submit Pull Request

---

**Setup Time:** 15 minutes  
**Monthly Cost:** $0 (Free tier sufficient)  
**Data Retention:** 30+ years on free tier