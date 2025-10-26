# Authority Collector Setup Guide
## Step-by-Step Installation for IndieCampers SEO Intelligence

**Estimated Time:** 60-90 minutes  
**Difficulty:** Intermediate  
**Cost:** $68/month (after setup)

---

## 📋 PRE-FLIGHT CHECKLIST

Before we begin, ensure you have:

- [ ] Email address for account creation
- [ ] Credit card (for DataForSEO - no charge during trial)
- [ ] Access to IndieCampers domains (to verify which domains to track)
- [ ] Slack workspace (optional - for alerts)
- [ ] 60-90 minutes of focused time

---

## 🎯 SETUP OVERVIEW

We'll set up 4 components in this order:

1. **Supabase** (Database) - 20 minutes
2. **DataForSEO** (API) - 10 minutes
3. **n8n** (Automation) - 15 minutes
4. **Authority Collector** (Workflow) - 30 minutes
5. **Testing & Activation** - 10 minutes

---

## PART 1: SUPABASE SETUP (Database)

### Step 1.1: Create Supabase Account

1. **Go to:** https://supabase.com
2. **Click:** "Start your project"
3. **Sign up with:** GitHub, Google, or Email
4. **Verify** your email if required

### Step 1.2: Create New Project

1. **Click:** "New Project"
2. **Fill in:**
   - Organization: Create new → "IndieCampers" (or use existing)
   - Project Name: `indiecampers-seo`
   - Database Password: **Generate strong password** (SAVE THIS!)
   - Region: **Europe (Frankfurt)** (closest to PT/ES/FR markets)
   - Pricing Plan: **Free** ($0/month - sufficient for 1+ years)

3. **Click:** "Create new project"
4. **Wait:** 2-3 minutes for project initialization

### Step 1.3: Save Your Credentials

Once project is ready, go to **Settings → API**

**Save these 3 values:**
```
Project URL: https://YOUR_PROJECT_ID.supabase.co
Project API Key (anon public): eyJhbGc...
Service Role Key (secret): eyJhbGc...
```

⚠️ **IMPORTANT:** You'll need the **Service Role Key** (not the anon key)

### Step 1.4: Run Database Schema

1. **Go to:** SQL Editor (left sidebar)
2. **Click:** "+ New query"
3. **Copy the entire schema** from GitHub:
   - URL: https://raw.githubusercontent.com/Kr8thor/indiecampers-seo-intelligence/main/config/supabase_schema.sql
   - Or use the schema I'll provide below

4. **Paste** the SQL into the editor
5. **Click:** "Run" (or press Ctrl+Enter)
6. **Verify:** Green success message appears

<details>
<summary>Click to expand full Supabase schema SQL</summary>

```sql
-- ============================================
-- INDIECAMPERS SEO INTELLIGENCE DATABASE SCHEMA
-- Version: 1.0 (Supabase/PostgreSQL)
-- ============================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================
-- TABLE 1: MARKETS (Reference Data)
-- ============================================
CREATE TABLE markets (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  code VARCHAR(2) UNIQUE NOT NULL,
  name VARCHAR(50) NOT NULL,
  location_code INTEGER NOT NULL,
  language_name VARCHAR(20) NOT NULL,
  domain VARCHAR(100) NOT NULL,
  active BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT NOW()
);

-- ============================================
-- TABLE 2: DAILY METRICS
-- ============================================
CREATE TABLE daily_metrics (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  market_id UUID REFERENCES markets(id) ON DELETE CASCADE,
  date DATE NOT NULL,
  
  -- Authority Metrics
  domain_rating INTEGER CHECK (domain_rating >= 0 AND domain_rating <= 100),
  domain_rating_delta DECIMAL(5,2),
  total_backlinks INTEGER,
  referring_domains INTEGER,
  dofollow_backlinks INTEGER,
  
  -- Ranking Metrics
  average_ranking DECIMAL(6,2),
  average_ranking_delta DECIMAL(6,2),
  total_ranked_keywords INTEGER,
  keywords_top_1 INTEGER,
  keywords_top_3 INTEGER,
  keywords_top_10 INTEGER,
  keywords_top_20 INTEGER,
  keywords_top_30 INTEGER,
  
  -- Traffic Metrics
  estimated_traffic_value DECIMAL(10,2),
  organic_keywords_count INTEGER,
  
  -- Metadata
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  
  UNIQUE(market_id, date)
);

-- Indexes
CREATE INDEX idx_daily_metrics_market_date ON daily_metrics(market_id, date DESC);
CREATE INDEX idx_daily_metrics_date ON daily_metrics(date DESC);

-- ============================================
-- TABLE 3: BACKLINKS
-- ============================================
CREATE TABLE backlinks (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  market_id UUID REFERENCES markets(id) ON DELETE CASCADE,
  
  domain_from VARCHAR(255) NOT NULL,
  domain_from_rank INTEGER CHECK (domain_from_rank >= 0 AND domain_from_rank <= 100),
  url_from TEXT,
  url_to TEXT,
  anchor TEXT,
  dofollow BOOLEAN DEFAULT true,
  
  first_seen DATE NOT NULL,
  last_checked DATE NOT NULL,
  status VARCHAR(20) DEFAULT 'active',
  
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  
  UNIQUE(market_id, domain_from, url_from, url_to)
);

CREATE INDEX idx_backlinks_market ON backlinks(market_id, last_checked DESC);
CREATE INDEX idx_backlinks_domain_rank ON backlinks(domain_from_rank DESC);
CREATE INDEX idx_backlinks_status ON backlinks(status, market_id);

-- ============================================
-- TABLE 4: TECHNICAL HEALTH
-- ============================================
CREATE TABLE technical_health (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  market_id UUID REFERENCES markets(id) ON DELETE CASCADE,
  audit_date DATE NOT NULL,
  
  pages_crawled INTEGER,
  technical_health_score DECIMAL(5,2) CHECK (technical_health_score >= 0 AND technical_health_score <= 100),
  
  broken_links INTEGER,
  duplicate_titles INTEGER,
  duplicate_descriptions INTEGER,
  duplicate_content INTEGER,
  broken_resources INTEGER,
  orphan_pages INTEGER,
  links_4xx INTEGER,
  links_5xx INTEGER,
  
  core_web_vitals_score DECIMAL(5,2) CHECK (core_web_vitals_score >= 0 AND core_web_vitals_score <= 100),
  lcp_value INTEGER,
  lcp_pass BOOLEAN,
  cls_value DECIMAL(6,3),
  cls_pass BOOLEAN,
  tbt_value INTEGER,
  tbt_pass BOOLEAN,
  
  critical_issues TEXT,
  has_critical_issues BOOLEAN DEFAULT false,
  
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  
  UNIQUE(market_id, audit_date)
);

CREATE INDEX idx_technical_market_date ON technical_health(market_id, audit_date DESC);
CREATE INDEX idx_technical_critical ON technical_health(has_critical_issues, market_id);

-- ============================================
-- TABLE 5: API COSTS
-- ============================================
CREATE TABLE api_costs (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  timestamp TIMESTAMP DEFAULT NOW(),
  
  workflow_name VARCHAR(100),
  market_id UUID REFERENCES markets(id) ON DELETE CASCADE,
  operation_type VARCHAR(50),
  
  cost_usd DECIMAL(10,4),
  api_provider VARCHAR(50),
  
  request_payload JSONB,
  response_metadata JSONB
);

CREATE INDEX idx_api_costs_timestamp ON api_costs(timestamp DESC);
CREATE INDEX idx_api_costs_market ON api_costs(market_id, timestamp DESC);
CREATE INDEX idx_api_costs_workflow ON api_costs(workflow_name, timestamp DESC);

-- ============================================
-- TABLE 6: CONVERSATION HISTORY
-- ============================================
CREATE TABLE conversation_history (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  
  user_id VARCHAR(50) NOT NULL,
  channel_id VARCHAR(50),
  thread_ts VARCHAR(50),
  
  question TEXT NOT NULL,
  response TEXT NOT NULL,
  intent VARCHAR(50),
  market_code VARCHAR(2),
  
  claude_model VARCHAR(50),
  tokens_used INTEGER,
  response_time_ms INTEGER,
  
  user_rating INTEGER CHECK (user_rating >= 1 AND user_rating <= 5),
  feedback TEXT,
  
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_conversation_user ON conversation_history(user_id, created_at DESC);
CREATE INDEX idx_conversation_thread ON conversation_history(thread_ts, created_at);
CREATE INDEX idx_conversation_intent ON conversation_history(intent, created_at DESC);

-- ============================================
-- AUTO-UPDATE TIMESTAMP FUNCTION
-- ============================================
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Apply to all tables with updated_at
CREATE TRIGGER update_daily_metrics_updated_at BEFORE UPDATE ON daily_metrics
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_backlinks_updated_at BEFORE UPDATE ON backlinks
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_technical_health_updated_at BEFORE UPDATE ON technical_health
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- VIEWS FOR EASY QUERYING
-- ============================================

-- Latest metrics per market
CREATE VIEW latest_metrics AS
SELECT 
  m.code,
  m.name,
  m.domain,
  dm.date,
  dm.domain_rating,
  dm.average_ranking,
  dm.keywords_top_10,
  dm.total_ranked_keywords,
  dm.total_backlinks,
  dm.referring_domains
FROM daily_metrics dm
JOIN markets m ON m.id = dm.market_id
WHERE dm.date = (
  SELECT MAX(date) 
  FROM daily_metrics 
  WHERE market_id = dm.market_id
);

-- 7-day trends
CREATE VIEW metrics_7day_trend AS
SELECT 
  m.code,
  m.name,
  dm.date,
  dm.domain_rating,
  dm.average_ranking,
  dm.domain_rating - LAG(dm.domain_rating) OVER (
    PARTITION BY m.id ORDER BY dm.date
  ) as dr_change,
  dm.average_ranking - LAG(dm.average_ranking) OVER (
    PARTITION BY m.id ORDER BY dm.date
  ) as ranking_change
FROM daily_metrics dm
JOIN markets m ON m.id = dm.market_id
WHERE dm.date >= CURRENT_DATE - INTERVAL '7 days'
ORDER BY m.code, dm.date DESC;

-- Monthly costs
CREATE VIEW monthly_api_costs AS
SELECT 
  DATE_TRUNC('month', timestamp) as month,
  api_provider,
  SUM(cost_usd) as total_cost,
  COUNT(*) as call_count
FROM api_costs
GROUP BY DATE_TRUNC('month', timestamp), api_provider
ORDER BY month DESC, api_provider;

-- High-authority backlinks
CREATE VIEW high_authority_backlinks AS
SELECT 
  m.code,
  m.name,
  COUNT(*) as backlink_count,
  AVG(b.domain_from_rank) as avg_domain_rank
FROM backlinks b
JOIN markets m ON m.id = b.market_id
WHERE b.status = 'active'
  AND b.domain_from_rank >= 35
GROUP BY m.code, m.name
ORDER BY backlink_count DESC;

-- ============================================
-- SEED DATA: MARKETS
-- ============================================
INSERT INTO markets (code, name, location_code, language_name, domain, active) VALUES
  ('PT', 'Portugal', 2620, 'Portuguese', 'indiecampers.pt', true),
  ('ES', 'Spain', 2724, 'Spanish', 'indiecampers.es', true),
  ('FR', 'France', 2250, 'French', 'indiecampers.fr', true),
  ('DE', 'Germany', 2276, 'German', 'indiecampers.de', true),
  ('UK', 'United Kingdom', 2826, 'English', 'indiecampers.co.uk', true);

-- ============================================
-- VERIFICATION QUERIES
-- ============================================
-- Run these to verify setup:

-- Check tables created
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public';

-- Check markets seeded
SELECT * FROM markets ORDER BY code;

-- Check views created
SELECT table_name 
FROM information_schema.views 
WHERE table_schema = 'public';
```

</details>

### Step 1.5: Verify Setup

Run these queries in SQL Editor to verify:

```sql
-- Should return 6 tables
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public'
ORDER BY table_name;

-- Should return 5 markets (PT, ES, FR, DE, UK)
SELECT * FROM markets ORDER BY code;

-- Should return 4 views
SELECT table_name 
FROM information_schema.views 
WHERE table_schema = 'public';
```

**Expected results:**
- 6 tables: api_costs, backlinks, conversation_history, daily_metrics, markets, technical_health
- 5 markets: PT, ES, FR, DE, UK
- 4 views: high_authority_backlinks, latest_metrics, metrics_7day_trend, monthly_api_costs

✅ **Checkpoint:** Supabase database is ready!

---

## PART 2: DATAFORSEO SETUP (API Access)

### Step 2.1: Create DataForSEO Account

1. **Go to:** https://dataforseo.com
2. **Click:** "Sign Up" (top right)
3. **Fill in:**
   - Email
   - Password
   - Company name: "IndieCampers"
4. **Verify** email

### Step 2.2: Get API Credentials

1. **Log in** to DataForSEO dashboard
2. **Go to:** Account → API Access
3. **Save these credentials:**
   ```
   Login: your@email.com
   Password: (API password shown on dashboard)
   ```

⚠️ **Note:** This is NOT your account password - it's a separate API password

### Step 2.3: Add Credits (Optional but Recommended)

1. **Go to:** Billing → Add Funds
2. **Add:** $20-50 for testing (1-2 months)
3. **Or:** Use $1 trial credit (very limited)

**Cost estimates:**
- Per run (5 markets): ~$0.60
- Daily for 1 month: ~$18
- First $20 = ~33 days of testing

### Step 2.4: Check API Status

**Test your credentials:**
```bash
# You can test in DataForSEO dashboard:
# Dashboard → API Playground → "Test Connection"
```

✅ **Checkpoint:** DataForSEO API ready!

---

## PART 3: N8N SETUP (Automation Platform)

### Option A: n8n Cloud (Recommended for Beginners)

#### Step 3A.1: Create n8n Cloud Account

1. **Go to:** https://n8n.io
2. **Click:** "Get started free"
3. **Sign up with:** Email or Google
4. **Choose plan:** Starter ($0 for trial, then $20/month)

#### Step 3A.2: Access Your Instance

1. **After signup:** You'll be redirected to your n8n instance
2. **URL:** https://YOUR-SUBDOMAIN.app.n8n.cloud
3. **Save this URL** - you'll need it

### Option B: Self-Hosted n8n (Advanced - Save $50/month)

<details>
<summary>Click to expand self-hosted instructions</summary>

**Prerequisites:** Docker installed

```bash
# Run n8n with Docker
docker run -it --rm \
  --name n8n \
  -p 5678:5678 \
  -e N8N_BASIC_AUTH_ACTIVE=true \
  -e N8N_BASIC_AUTH_USER=admin \
  -e N8N_BASIC_AUTH_PASSWORD=your_password \
  -v ~/.n8n:/home/node/.n8n \
  n8nio/n8n

# Access at: http://localhost:5678
```

**Pros:** Free, full control  
**Cons:** You manage updates, backups, uptime

</details>

✅ **Checkpoint:** n8n instance ready!

---

## PART 4: CONFIGURE N8N CREDENTIALS

### Step 4.1: Add Supabase Credentials

1. **In n8n:** Go to **Credentials** (left sidebar)
2. **Click:** "+ Add Credential"
3. **Search:** "Supabase"
4. **Fill in:**
   - Credential Name: `IndieCampers Supabase`
   - Host: `https://YOUR_PROJECT_ID.supabase.co` (from Step 1.3)
   - Service Role Secret: `eyJhbGc...` (Service Role Key from Step 1.3)
5. **Click:** "Save"

### Step 4.2: Add DataForSEO Credentials

1. **Click:** "+ Add Credential"
2. **Search:** "DataForSEO"
3. **Fill in:**
   - Credential Name: `IndieCampers DataForSEO`
   - Login: Your DataForSEO email (from Step 2.2)
   - Password: Your DataForSEO API password (from Step 2.2)
4. **Click:** "Test" to verify
5. **Click:** "Save"

### Step 4.3: Add Slack Credentials (Optional)

<details>
<summary>Click to expand Slack setup (skip if you don't want alerts)</summary>

#### Create Slack Webhook

1. **Go to:** https://api.slack.com/apps
2. **Click:** "Create New App" → "From scratch"
3. **App Name:** "IndieCampers SEO Alerts"
4. **Workspace:** Select your workspace
5. **Click:** "Create App"
6. **Go to:** "Incoming Webhooks"
7. **Toggle:** "Activate Incoming Webhooks" → ON
8. **Click:** "Add New Webhook to Workspace"
9. **Select channel:** #seo-alerts (or create new channel)
10. **Copy:** Webhook URL (starts with `https://hooks.slack.com/...`)

#### Add to n8n

1. **In n8n:** Credentials → "+ Add Credential"
2. **Search:** "Slack"
3. **Choose:** "Slack Webhook"
4. **Paste:** Webhook URL
5. **Save**

</details>

✅ **Checkpoint:** All credentials configured!

---

## PART 5: IMPORT AUTHORITY COLLECTOR WORKFLOW

### Step 5.1: Download Workflow File

**Option A: From GitHub (Direct)**
1. **Go to:** https://raw.githubusercontent.com/Kr8thor/indiecampers-seo-intelligence/main/workflows/Authority_Collector_Supabase.json
2. **Right-click** → "Save As"
3. **Save:** `Authority_Collector_Supabase.json`

**Option B: From Your Downloaded Package**
- Use the file: `Authority_Collector_Supabase.json` from `/tmp/indiecampers-workflows/`

### Step 5.2: Import to n8n

1. **In n8n:** Click "Workflows" (left sidebar)
2. **Click:** "+ Add Workflow"
3. **Click:** "Import from File" (top right menu)
4. **Select:** `Authority_Collector_Supabase.json`
5. **Click:** "Import"

**You should see:** 14 nodes arranged in a workflow

### Step 5.3: Configure Credentials in Workflow

Now we need to assign the credentials we created to each node:

#### Nodes that need Supabase credentials (5 nodes):

1. **"Get Active Markets"**
   - Click the node
   - Under "Credential to connect with": Select `IndieCampers Supabase`

2. **"Upsert Daily Metrics"**
   - Click the node
   - Select: `IndieCampers Supabase`

3. **"Log API Costs"**
   - Click the node
   - Select: `IndieCampers Supabase`

4. **"Get Metrics With Deltas"**
   - Click the node
   - Select: `IndieCampers Supabase`

#### Nodes that need DataForSEO credentials (2 nodes):

5. **"Get Keywords For Site"**
   - Click the node
   - Under "Credential to connect with": Select `IndieCampers DataForSEO`

6. **"Get Backlink Summary"**
   - Click the node
   - Select: `IndieCampers DataForSEO`

#### Node that needs Slack credentials (1 node - optional):

7. **"Send Slack Alert"**
   - Click the node
   - Select: Your Slack credential
   - **Or:** Delete this node if you don't want alerts

### Step 5.4: Verify Domain Names

Check that the domains in your Supabase `markets` table match your actual domains:

1. **Go to Supabase:** Table Editor → markets
2. **Verify domains:**
   - PT: `indiecampers.pt` ← Is this correct?
   - ES: `indiecampers.es`
   - FR: `indiecampers.fr`
   - DE: `indiecampers.de`
   - UK: `indiecampers.co.uk`

**If domains are different:**
```sql
-- Update in Supabase SQL Editor:
UPDATE markets SET domain = 'correct-domain.pt' WHERE code = 'PT';
-- Repeat for each market as needed
```

### Step 5.5: Save Workflow

1. **Click:** "Save" (top right)
2. **Workflow name:** Keep as "Authority Collector - Daily Metrics (Supabase)"

✅ **Checkpoint:** Workflow imported and configured!

---

## PART 6: TEST THE WORKFLOW (DRY RUN)

### Step 6.1: Disable Schedule Trigger

1. **Click:** "Schedule Trigger" node (first node)
2. **Toggle:** "Enabled" → OFF (we'll test manually first)

### Step 6.2: Run Test with One Market

Let's test with just Portugal first to save API credits:

1. **In Supabase:** Temporarily disable other markets:
   ```sql
   UPDATE markets SET active = false WHERE code != 'PT';
   ```

2. **In n8n:** Click "Test workflow" (top right)

### Step 6.3: Monitor Execution

You'll see nodes light up as they execute:

**Expected flow:**
1. ✅ Schedule Trigger (bypassed in test)
2. ✅ Get Active Markets (fetches PT only)
3. ✅ Loop Over Markets (1 iteration)
4. ✅ Get Keywords For Site (DataForSEO API call)
5. ✅ Get Backlink Summary (DataForSEO API call)
6. ✅ Transform & Calculate Metrics
7. ✅ Upsert Daily Metrics (writes to Supabase)
8. ✅ Log API Costs
9. ✅ Get Metrics With Deltas
10. ✅ Detect Anomalies
11. ⚠️ If Anomalies Detected (might skip if no previous data)
12. ⚠️ Send Slack Alert (only if anomaly)
13. ✅ Merge
14. ✅ More Markets? (no more markets)

**Execution time:** 10-20 seconds

### Step 6.4: Check for Errors

**If you see red nodes:**

1. **Click the red node**
2. **Check error message:**
   - "Permission denied" → Check Supabase credentials
   - "Invalid API key" → Check DataForSEO credentials
   - "Relation does not exist" → Re-run schema SQL
   - "Rate limit" → Wait 1 minute, try again

3. **Fix the issue**
4. **Run test again**

### Step 6.5: Verify Data in Supabase

**Go to Supabase → Table Editor:**

1. **Check `daily_metrics` table:**
   ```sql
   SELECT * FROM daily_metrics ORDER BY date DESC LIMIT 5;
   ```
   
   **Expected:** 1 new row for PT with today's date
   
   **Verify columns have values:**
   - domain_rating (e.g., 45)
   - average_ranking (e.g., 16.5)
   - total_backlinks (e.g., 12,543)
   - keywords_top_10 (e.g., 87)

2. **Check `api_costs` table:**
   ```sql
   SELECT * FROM api_costs ORDER BY timestamp DESC LIMIT 5;
   ```
   
   **Expected:** 2 new rows
   - One for "ranked_keywords" (~$0.10)
   - One for "backlinks_summary" (~$0.02)

### Step 6.6: View Results in n8n

Click each node to see what data flowed through:

**"Get Keywords For Site" output:**
- Should show array of keywords with ranks
- Example: `{"keyword": "campervan portugal", "rank": 3, "search_volume": 880}`

**"Transform & Calculate Metrics" output:**
- Should show calculated metrics
- Example: `{"domain_rating": 45, "average_ranking": 16.2, "keywords_top_10": 87}`

✅ **Checkpoint:** Test successful for Portugal!

---

## PART 7: ENABLE ALL MARKETS & ACTIVATE

### Step 7.1: Re-enable All Markets

```sql
-- In Supabase SQL Editor:
UPDATE markets SET active = true;

-- Verify:
SELECT code, name, active FROM markets ORDER BY code;
```

**Expected:** All 5 markets show `active = true`

### Step 7.2: Configure Schedule

1. **Click:** "Schedule Trigger" node
2. **Toggle:** "Enabled" → ON
3. **Verify schedule:** "0 8 * * *" (runs at 08:00 UTC daily)

**Adjust time if needed:**
- 08:00 UTC = 09:00 Lisbon time (winter) / 10:00 (summer)
- Want different time? Use cron expression: https://crontab.guru

### Step 7.3: Save and Activate

1. **Click:** "Save" (top right)
2. **Toggle:** "Active" (top right) → ON
3. **Confirm:** Workflow shows as "Active"

### Step 7.4: Run Full Test (All Markets)

**Optional but recommended:**

1. **Click:** "Test workflow"
2. **Monitor:** All 5 markets process (takes 60-90 seconds)
3. **Verify:** 5 new rows in daily_metrics table

**In Supabase:**
```sql
SELECT 
  m.code,
  dm.date,
  dm.domain_rating,
  dm.average_ranking,
  dm.keywords_top_10
FROM daily_metrics dm
JOIN markets m ON m.id = dm.market_id
WHERE dm.date = CURRENT_DATE
ORDER BY m.code;
```

**Expected:** 5 rows (PT, ES, FR, DE, UK) with today's metrics

✅ **Checkpoint:** Authority Collector is LIVE!

---

## PART 8: VERIFY AUTOMATION

### Step 8.1: Check Tomorrow Morning

**The next day (after 08:00 UTC):**

1. **Go to n8n:** Executions tab
2. **Verify:** New execution shows "Success"
3. **Check time:** Around 08:00 UTC

### Step 8.2: Query Latest Data

**In Supabase:**
```sql
-- View latest metrics for all markets
SELECT * FROM latest_metrics;

-- View 7-day trend
SELECT * FROM metrics_7day_trend;
```

### Step 8.3: Test Slack Alerts (If Enabled)

To force an alert (for testing):

1. **In Supabase:** Manually change yesterday's DR:
   ```sql
   -- Make yesterday's DR much lower to trigger alert
   UPDATE daily_metrics 
   SET domain_rating = domain_rating - 10
   WHERE date = CURRENT_DATE - INTERVAL '1 day'
     AND market_id = (SELECT id FROM markets WHERE code = 'PT');
   ```

2. **In n8n:** Run test workflow
3. **Check Slack:** You should see alert in #seo-alerts

4. **Reset data:**
   ```sql
   UPDATE daily_metrics 
   SET domain_rating = domain_rating + 10
   WHERE date = CURRENT_DATE - INTERVAL '1 day'
     AND market_id = (SELECT id FROM markets WHERE code = 'PT');
   ```

---

## 🎉 CONGRATULATIONS! SETUP COMPLETE

Your Authority Collector is now running automatically! 

**What happens now:**
- ✅ Every day at 08:00 UTC:
  - Fetches SEO metrics for all 5 markets
  - Saves to Supabase database
  - Calculates trends vs yesterday
  - Sends Slack alerts if big changes detected
  
- ✅ You can view data anytime:
  - Supabase dashboard (real-time)
  - Build custom Supabase queries
  - Export to Google Sheets (future enhancement)

---

## 📊 WHAT TO DO NEXT

### Immediate Actions (Today):

1. **Bookmark these URLs:**
   - n8n: https://YOUR-SUBDOMAIN.app.n8n.cloud
   - Supabase: https://supabase.com/dashboard/project/YOUR_PROJECT_ID
   - DataForSEO: https://app.dataforseo.com

2. **Save your credentials:** In password manager

3. **Join #seo-alerts** in Slack (if using alerts)

### This Week:

1. **Monitor daily executions:**
   - Check n8n Executions tab daily
   - Verify data appearing in Supabase

2. **Review first week's data:**
   ```sql
   SELECT * FROM metrics_7day_trend;
   ```

3. **Set up cost alerts:**
   - DataForSEO dashboard → Billing → Set alert at $30

### This Month:

1. **Analyze trends:**
   - Which market has best DR?
   - Which market improved most?
   - Where are we losing rankings?

2. **Optimize costs:**
   - Disable markets you don't need
   - Adjust frequency (daily → weekly)

3. **Enhance workflow (optional):**
   - Add more metrics (page speed, etc.)
   - Add more markets
   - Build dashboards in Supabase

---

## 🛠️ TROUBLESHOOTING

### Common Issues

#### Issue: "No data appearing in Supabase"

**Diagnosis:**
```sql
-- Check if workflow ran
SELECT * FROM api_costs ORDER BY timestamp DESC LIMIT 10;
```

**Solutions:**
- If no rows: Workflow didn't run → Check n8n executions
- If rows exist but no metrics: Check daily_metrics for errors

#### Issue: "DataForSEO API errors"

**Error:** "Insufficient credits"
- **Solution:** Add funds in DataForSEO dashboard

**Error:** "Invalid location code"
- **Solution:** Verify location codes in markets table match DataForSEO codes
- Check: https://dataforseo.com/apis/serp-api/google/locations

**Error:** "Rate limit exceeded"
- **Solution:** Workflow processes sequentially, shouldn't happen
- If it does: Add 10-second delay between markets

#### Issue: "Slack alerts not working"

**Check:**
1. Webhook URL correct?
2. Channel exists?
3. Node has Slack credential assigned?
4. Are anomalies actually detected? (Check "Detect Anomalies" node output)

**Force test:**
```sql
-- Create fake anomaly
UPDATE daily_metrics 
SET domain_rating = 10, average_ranking = 50
WHERE date = CURRENT_DATE AND market_id = (SELECT id FROM markets WHERE code = 'PT');
```

Then run test workflow - should trigger alert.

#### Issue: "Workflow taking too long"

**Normal times:**
- 1 market: 10-15 seconds
- 5 markets: 60-90 seconds

**If slower:**
- Check DataForSEO API status
- Check Supabase connection
- Check n8n instance resources (Cloud plan limits)

---

## 💰 COST TRACKING

### View Your Costs

**DataForSEO:**
- Dashboard → Billing → Transaction History

**In Supabase:**
```sql
-- Today's cost
SELECT SUM(cost_usd) as today_cost 
FROM api_costs 
WHERE DATE(timestamp) = CURRENT_DATE;

-- This month's cost
SELECT 
  DATE(timestamp) as date,
  SUM(cost_usd) as daily_cost
FROM api_costs
WHERE timestamp >= DATE_TRUNC('month', CURRENT_DATE)
GROUP BY DATE(timestamp)
ORDER BY date;

-- Cost per market
SELECT 
  m.code,
  COUNT(*) as api_calls,
  SUM(ac.cost_usd) as total_cost
FROM api_costs ac
JOIN markets m ON m.id = ac.market_id
WHERE timestamp >= DATE_TRUNC('month', CURRENT_DATE)
GROUP BY m.code
ORDER BY total_cost DESC;
```

### Expected Monthly Costs

**Current setup (5 markets, daily):**
- DataForSEO: ~$18/month
- n8n Cloud: $20-50/month (or $0 if self-hosted)
- Supabase: $0 (free tier)
- **Total: $38-68/month**

---

## 📚 USEFUL QUERIES

### Daily Summary
```sql
SELECT 
  m.code as market,
  dm.date,
  dm.domain_rating as dr,
  dm.average_ranking as avg_rank,
  dm.keywords_top_10 as top10,
  dm.total_backlinks as backlinks
FROM daily_metrics dm
JOIN markets m ON m.id = dm.market_id
WHERE dm.date >= CURRENT_DATE - INTERVAL '7 days'
ORDER BY m.code, dm.date DESC;
```

### Best Performing Market
```sql
SELECT 
  m.code,
  AVG(dm.domain_rating) as avg_dr,
  AVG(dm.keywords_top_10) as avg_top10
FROM daily_metrics dm
JOIN markets m ON m.id = dm.market_id
WHERE dm.date >= CURRENT_DATE - INTERVAL '30 days'
GROUP BY m.code
ORDER BY avg_dr DESC;
```

### Biggest Changes (Last 7 Days)
```sql
WITH changes AS (
  SELECT 
    m.code,
    dm.domain_rating - LAG(dm.domain_rating) OVER (PARTITION BY m.id ORDER BY dm.date) as dr_change,
    dm.average_ranking - LAG(dm.average_ranking) OVER (PARTITION BY m.id ORDER BY dm.date) as rank_change,
    dm.date
  FROM daily_metrics dm
  JOIN markets m ON m.id = dm.market_id
  WHERE dm.date >= CURRENT_DATE - INTERVAL '7 days'
)
SELECT * FROM changes
WHERE ABS(dr_change) > 2 OR ABS(rank_change) > 2
ORDER BY date DESC;
```

---

## 🔒 SECURITY CHECKLIST

- [ ] Supabase Service Role Key stored securely (not in code)
- [ ] DataForSEO API password never shared
- [ ] n8n instance protected with authentication
- [ ] Slack webhook URL kept private
- [ ] Credentials backed up in password manager
- [ ] Team members have separate n8n accounts (don't share)

---

## 📞 SUPPORT

**Need help?**

1. **Check n8n logs:**
   - Workflow → Executions → Click failed execution
   - Look for error message

2. **Check Supabase logs:**
   - Logs Explorer → Filter by error

3. **Community support:**
   - n8n: https://community.n8n.io
   - DataForSEO: support@dataforseo.com
   - GitHub Issues: https://github.com/Kr8thor/indiecampers-seo-intelligence/issues

4. **Emergency:** Check PROJECT_STATUS_ANALYSIS.md for detailed troubleshooting

---

## ✅ FINAL CHECKLIST

Setup complete when ALL are checked:

- [ ] Supabase project created
- [ ] Schema applied (6 tables, 4 views)
- [ ] 5 markets seeded and verified
- [ ] DataForSEO account active with credits
- [ ] n8n instance running (Cloud or self-hosted)
- [ ] All 3 credentials configured in n8n
- [ ] Workflow imported to n8n
- [ ] All 7 nodes have credentials assigned
- [ ] Test run successful for 1 market
- [ ] Test run successful for all 5 markets
- [ ] Data visible in Supabase tables
- [ ] Schedule enabled (daily at 08:00 UTC)
- [ ] Workflow activated (toggle ON)
- [ ] First automated run verified next day
- [ ] Slack alerts tested (if enabled)
- [ ] Bookmarks and credentials saved

---

**🎊 YOU DID IT! Authority Collector is live and tracking your SEO metrics automatically!**

**Questions? Issues? Found this helpful?**  
Open an issue on GitHub or reach out to the n8n community.

---

**Setup Guide Version:** 1.0  
**Last Updated:** October 26, 2025  
**Status:** Production Ready