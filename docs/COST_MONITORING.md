# Cost Monitoring & Optimization Guide

Complete guide to monitoring, tracking, and optimizing API costs for the IndieCampers SEO Intelligence system.

---

## Table of Contents

- [Overview](#overview)
- [Cost Breakdown](#cost-breakdown)
- [Real-time Monitoring](#real-time-monitoring)
- [Cost Analysis Queries](#cost-analysis-queries)
- [Budget Alerts](#budget-alerts)
- [Optimization Strategies](#optimization-strategies)
- [Cost Forecasting](#cost-forecasting)

---

## Overview

### Monthly Cost Structure

```
┌─────────────────────────────────────┐
│ Fixed Costs (Monthly)               │
├─────────────────────────────────────┤
│ n8n Cloud          │ $20-50         │
│ Supabase (Free)    │ $0             │
│ Slack              │ $0             │
│ Total Fixed        │ $20-50         │
└─────────────────────────────────────┘

┌──────────────────────────────────────┐
│ Variable Costs (Per Run)             │
├──────────────────────────────────────┤
│ Authority Collector │ $0.60/run      │
│ Full Pipeline (1 mkt) │ $3-4/run     │
│ Full Pipeline (5 mkt) │ $15-20/run   │
└──────────────────────────────────────┘

┌──────────────────────────────────────┐
│ Recommended Monthly Budget           │
├──────────────────────────────────────┤
│ Daily Authority     │ $18/month      │
│ Weekly Full Pipeline│ $60-80/month   │
│ Total Recommended   │ $100-130/month │
└──────────────────────────────────────┘
```

### Cost Tracking Locations

**DataForSEO Dashboard:**
- Real-time credit balance
- Historical usage
- Per-endpoint costs

**Supabase `api_costs` Table:**
- Detailed cost logs
- Per-workflow tracking
- Per-market breakdown

**n8n Execution Logs:**
- Workflow run count
- Execution duration
- Failure rate

---

## Cost Breakdown

### DataForSEO API Costs

| API Endpoint | Cost/Call | Used By | Calls/Run (5 mkt) |
|--------------|-----------|---------|-------------------|
| Keywords for Site | $0.05 | Target snapshot | 10 (2×5) |
| Domain Competitors | $0.03 | Competitor discovery | 10 (2×5) |
| Keywords Data | $0.05 | Competitor keywords | 200 (20×10) |
| Backlinks Summary | $0.01 | Authority metrics | 200 (20×10) |
| SERP Organic | $0.05 | SERP analysis | 50 |
| **Total per run** | - | - | **~$15-20** |

### Authority Collector Costs (Optimized)

| Component | Cost/Call | Calls/Run | Total |
|-----------|-----------|-----------|-------|
| Ranked Keywords | $0.05 | 5 markets | $0.25 |
| Backlink Summary | $0.01 | 5 markets | $0.05 |
| Supabase writes | $0.00 | Unlimited | $0.00 |
| **Total** | - | - | **$0.30** |

*Note: Actual costs may be ~$0.60 due to retries and data size*

---

## Real-time Monitoring

### Supabase Queries

#### Today's Costs

```sql
-- Total cost today
SELECT
  SUM(cost_usd) as today_cost,
  COUNT(*) as api_calls,
  COUNT(DISTINCT workflow_name) as workflows_run
FROM api_costs
WHERE DATE(timestamp) = CURRENT_DATE;
```

**Expected Output:**
```
today_cost | api_calls | workflows_run
-----------+-----------+--------------
 0.60      | 10        | 1
```

#### This Week's Costs

```sql
-- Daily costs for the week
SELECT
  DATE(timestamp) as date,
  SUM(cost_usd) as daily_cost,
  COUNT(*) as api_calls,
  STRING_AGG(DISTINCT workflow_name, ', ') as workflows
FROM api_costs
WHERE timestamp >= DATE_TRUNC('week', CURRENT_DATE)
GROUP BY DATE(timestamp)
ORDER BY date DESC;
```

#### This Month's Costs

```sql
-- Monthly summary
SELECT
  DATE_TRUNC('month', timestamp) as month,
  SUM(cost_usd) as total_cost,
  AVG(cost_usd) as avg_cost_per_call,
  COUNT(*) as total_calls,
  COUNT(DISTINCT DATE(timestamp)) as days_with_runs
FROM api_costs
WHERE timestamp >= DATE_TRUNC('month', CURRENT_DATE)
GROUP BY month;
```

**Expected Output:**
```
month      | total_cost | avg_cost_per_call | total_calls | days_with_runs
-----------+------------+-------------------+-------------+----------------
2025-11-01 | 18.50      | 0.0370            | 500         | 8
```

#### Running Total (Burn Rate)

```sql
-- Cumulative cost this month
SELECT
  DATE(timestamp) as date,
  SUM(cost_usd) as daily_cost,
  SUM(SUM(cost_usd)) OVER (
    ORDER BY DATE(timestamp)
  ) as cumulative_cost,
  -- Projected end-of-month cost
  (SUM(SUM(cost_usd)) OVER (ORDER BY DATE(timestamp)) /
   EXTRACT(DAY FROM CURRENT_DATE)) *
   EXTRACT(DAY FROM DATE_TRUNC('month', CURRENT_DATE) + INTERVAL '1 month' - INTERVAL '1 day')
   as projected_monthly
FROM api_costs
WHERE timestamp >= DATE_TRUNC('month', CURRENT_DATE)
GROUP BY DATE(timestamp)
ORDER BY date;
```

---

## Cost Analysis Queries

### By Workflow

```sql
-- Cost breakdown by workflow
SELECT
  workflow_name,
  COUNT(*) as runs,
  SUM(cost_usd) as total_cost,
  AVG(cost_usd) as avg_cost_per_run,
  MIN(cost_usd) as min_cost,
  MAX(cost_usd) as max_cost
FROM api_costs
WHERE timestamp >= CURRENT_DATE - INTERVAL '30 days'
GROUP BY workflow_name
ORDER BY total_cost DESC;
```

**Example Output:**
```
workflow_name                  | runs | total_cost | avg_cost_per_run
-------------------------------+------+------------+-----------------
seo-intelligence-pipeline      | 4    | 72.00      | 18.00
Authority_Collector_Supabase   | 30   | 18.00      | 0.60
```

### By Market

```sql
-- Cost per market
SELECT
  m.code as market,
  m.name,
  COUNT(ac.*) as api_calls,
  SUM(ac.cost_usd) as total_cost,
  AVG(ac.cost_usd) as avg_cost_per_call
FROM api_costs ac
JOIN markets m ON m.id = ac.market_id
WHERE ac.timestamp >= CURRENT_DATE - INTERVAL '30 days'
GROUP BY m.code, m.name
ORDER BY total_cost DESC;
```

### By Operation Type

```sql
-- Cost by operation type
SELECT
  operation_type,
  COUNT(*) as calls,
  SUM(cost_usd) as total_cost,
  AVG(cost_usd) as avg_cost,
  SUM(cost_usd) * 100.0 / SUM(SUM(cost_usd)) OVER() as pct_of_total
FROM api_costs
WHERE timestamp >= CURRENT_DATE - INTERVAL '30 days'
GROUP BY operation_type
ORDER BY total_cost DESC;
```

**Example Output:**
```
operation_type      | calls | total_cost | avg_cost | pct_of_total
--------------------+-------+------------+----------+-------------
competitor_keywords | 400   | 20.00      | 0.05     | 50.0%
ranked_keywords     | 200   | 10.00      | 0.05     | 25.0%
backlinks_summary   | 200   | 2.00       | 0.01     | 5.0%
```

### Cost Trends

```sql
-- Week-over-week comparison
WITH weekly_costs AS (
  SELECT
    DATE_TRUNC('week', timestamp) as week,
    SUM(cost_usd) as weekly_cost
  FROM api_costs
  GROUP BY week
)
SELECT
  week,
  weekly_cost,
  LAG(weekly_cost) OVER (ORDER BY week) as previous_week,
  weekly_cost - LAG(weekly_cost) OVER (ORDER BY week) as change,
  ROUND(
    ((weekly_cost - LAG(weekly_cost) OVER (ORDER BY week)) * 100.0 /
    LAG(weekly_cost) OVER (ORDER BY week))::numeric,
    1
  ) as pct_change
FROM weekly_costs
ORDER BY week DESC
LIMIT 8;
```

### Expensive Runs

```sql
-- Find most expensive workflow runs
WITH run_costs AS (
  SELECT
    workflow_name,
    DATE(timestamp) as run_date,
    SUM(cost_usd) as run_cost,
    COUNT(*) as api_calls
  FROM api_costs
  GROUP BY workflow_name, DATE(timestamp)
)
SELECT
  run_date,
  workflow_name,
  run_cost,
  api_calls,
  run_cost / api_calls as avg_cost_per_call
FROM run_costs
WHERE run_date >= CURRENT_DATE - INTERVAL '30 days'
ORDER BY run_cost DESC
LIMIT 10;
```

---

## Budget Alerts

### SQL-Based Alerts

#### Daily Budget Check

```sql
-- Check if today's cost exceeds daily budget
WITH daily_budget AS (
  SELECT 5.00 as max_daily_cost  -- Set your daily budget here
),
today_cost AS (
  SELECT COALESCE(SUM(cost_usd), 0) as cost
  FROM api_costs
  WHERE DATE(timestamp) = CURRENT_DATE
)
SELECT
  today_cost.cost as todays_cost,
  daily_budget.max_daily_cost as budget,
  CASE
    WHEN today_cost.cost > daily_budget.max_daily_cost THEN '⚠️ OVER BUDGET'
    WHEN today_cost.cost > daily_budget.max_daily_cost * 0.8 THEN '⚡ Warning (80%)'
    ELSE '✅ Within Budget'
  END as status,
  daily_budget.max_daily_cost - today_cost.cost as remaining
FROM today_cost, daily_budget;
```

#### Monthly Budget Check

```sql
-- Check monthly budget progress
WITH monthly_budget AS (
  SELECT 100.00 as max_monthly_cost  -- Set your monthly budget
),
month_cost AS (
  SELECT COALESCE(SUM(cost_usd), 0) as cost
  FROM api_costs
  WHERE timestamp >= DATE_TRUNC('month', CURRENT_DATE)
),
days_data AS (
  SELECT
    EXTRACT(DAY FROM CURRENT_DATE) as days_elapsed,
    EXTRACT(DAY FROM DATE_TRUNC('month', CURRENT_DATE) + INTERVAL '1 month' - INTERVAL '1 day') as days_in_month
)
SELECT
  month_cost.cost as current_cost,
  monthly_budget.max_monthly_cost as budget,
  ROUND((month_cost.cost * 100.0 / monthly_budget.max_monthly_cost)::numeric, 1) as pct_used,
  -- Projected cost
  ROUND((month_cost.cost * days_data.days_in_month / days_data.days_elapsed)::numeric, 2) as projected_cost,
  CASE
    WHEN month_cost.cost > monthly_budget.max_monthly_cost THEN '🚨 OVER BUDGET'
    WHEN month_cost.cost > monthly_budget.max_monthly_cost * 0.9 THEN '⚠️ Warning (90%)'
    WHEN month_cost.cost > monthly_budget.max_monthly_cost * 0.75 THEN '⚡ Caution (75%)'
    ELSE '✅ On Track'
  END as status
FROM month_cost, monthly_budget, days_data;
```

### n8n Workflow Alert

Add this to your workflow to send alerts when budget is exceeded:

```javascript
// Check Budget Node (Code node)
const budget = {
  daily: 5.00,
  monthly: 100.00
};

// Query Supabase for costs
const todayCost = $node["Get Today Cost"].json.total || 0;
const monthCost = $node["Get Month Cost"].json.total || 0;

const alerts = [];

if (todayCost > budget.daily) {
  alerts.push({
    type: 'daily',
    message: `⚠️ Daily budget exceeded: $${todayCost} / $${budget.daily}`,
    severity: 'high'
  });
}

if (monthCost > budget.monthly * 0.9) {
  alerts.push({
    type: 'monthly',
    message: `⚡ Monthly budget at ${(monthCost/budget.monthly*100).toFixed(0)}%: $${monthCost} / $${budget.monthly}`,
    severity: 'medium'
  });
}

return alerts.map(a => ({ json: a }));
```

---

## Optimization Strategies

### Strategy 1: Reduce Run Frequency

**Impact:** Linear cost reduction

```sql
-- Current cost (daily runs)
SELECT 30 * 0.60 as monthly_cost_daily;
-- Result: $18/month

-- Optimized cost (every 3 days)
SELECT 10 * 0.60 as monthly_cost_3days;
-- Result: $6/month (66% reduction)
```

### Strategy 2: Reduce Markets

**Impact:** Proportional cost reduction

```javascript
// Before: 5 markets
MARKETS: ["PT", "ES", "FR", "DE", "UK"]  // Cost: $15-20/run

// After: 2 priority markets
MARKETS: ["PT", "ES"]  // Cost: $6-8/run (60% reduction)
```

### Strategy 3: Reduce Competitors

**Impact:** 50% cost reduction

```javascript
// Before: 20 competitors
MAX_COMPETITORS_PER_MARKET: 20  // Cost: $15/run

// After: 10 competitors
MAX_COMPETITORS_PER_MARKET: 10  // Cost: $7.50/run
```

### Strategy 4: Reduce Keywords per Competitor

**Impact:** Proportional cost reduction

```javascript
// Before: 1000 keywords
TOP_KEYWORDS_PER_DOMAIN: 1000  // Cost: $10/competitor

// After: 500 keywords
TOP_KEYWORDS_PER_DOMAIN: 500  // Cost: $5/competitor (50% reduction)
```

### Strategy 5: Use Authority Collector for Daily

**Impact:** 97% cost reduction vs full pipeline

```
Full Pipeline Daily: $15 × 30 = $450/month
Authority Collector Daily: $0.60 × 30 = $18/month
Savings: $432/month (96%)

Recommendation:
- Daily: Authority Collector
- Weekly: Full Pipeline
Total: $18 + (4 × $15) = $78/month
```

### Cost Optimization Decision Matrix

```sql
-- Calculate ROI for each market
WITH market_value AS (
  SELECT
    m.code,
    AVG(dm.keywords_top_10) as avg_top10_keywords,
    AVG(dm.domain_rating) as avg_domain_rating,
    -- Estimate market value (customize formula)
    (AVG(dm.keywords_top_10) * 100 + AVG(dm.domain_rating) * 50) as value_score
  FROM markets m
  JOIN daily_metrics dm ON dm.market_id = m.id
  WHERE dm.date >= CURRENT_DATE - INTERVAL '30 days'
  GROUP BY m.code
),
market_costs AS (
  SELECT
    m.code,
    SUM(ac.cost_usd) as total_cost
  FROM markets m
  JOIN api_costs ac ON ac.market_id = m.id
  WHERE ac.timestamp >= CURRENT_DATE - INTERVAL '30 days'
  GROUP BY m.code
)
SELECT
  mv.code,
  mv.value_score,
  mc.total_cost,
  ROUND((mv.value_score / mc.total_cost)::numeric, 2) as roi_ratio,
  CASE
    WHEN mv.value_score / mc.total_cost > 100 THEN '✅ High ROI - Keep'
    WHEN mv.value_score / mc.total_cost > 50 THEN '⚡ Medium ROI - Review'
    ELSE '❌ Low ROI - Consider Removing'
  END as recommendation
FROM market_value mv
JOIN market_costs mc ON mc.code = mv.code
ORDER BY roi_ratio DESC;
```

---

## Cost Forecasting

### Simple Linear Projection

```sql
-- Project next month's cost based on current trend
WITH daily_avg AS (
  SELECT
    AVG(daily_cost) as avg_daily_cost
  FROM (
    SELECT
      DATE(timestamp) as date,
      SUM(cost_usd) as daily_cost
    FROM api_costs
    WHERE timestamp >= CURRENT_DATE - INTERVAL '14 days'
    GROUP BY DATE(timestamp)
  ) daily_costs
)
SELECT
  avg_daily_cost,
  avg_daily_cost * 30 as projected_monthly,
  avg_daily_cost * 365 as projected_yearly
FROM daily_avg;
```

### Scenario Planning

```sql
-- Compare different scenarios
SELECT
  'Current (Full Daily)' as scenario,
  15.00 * 30 as monthly_cost
UNION ALL
SELECT
  'Optimized (Auth Daily + Full Weekly)',
  (0.60 * 30) + (15.00 * 4)
UNION ALL
SELECT
  'Budget (Auth Daily + Full Biweekly)',
  (0.60 * 30) + (15.00 * 2)
UNION ALL
SELECT
  'Minimal (Auth Weekly)',
  0.60 * 4
ORDER BY monthly_cost DESC;
```

**Output:**
```
scenario                                  | monthly_cost
-----------------------------------------+-------------
Current (Full Daily)                     | 450.00
Optimized (Auth Daily + Full Weekly)     | 78.00
Budget (Auth Daily + Full Biweekly)      | 48.00
Minimal (Auth Weekly)                    | 2.40
```

---

## Dashboard Queries (for Visualization)

### Cost Over Time (Chart Data)

```sql
-- Daily costs for last 30 days (for line chart)
SELECT
  DATE(timestamp) as date,
  SUM(cost_usd) as cost
FROM api_costs
WHERE timestamp >= CURRENT_DATE - INTERVAL '30 days'
GROUP BY DATE(timestamp)
ORDER BY date;
```

### Cost by Category (Pie Chart)

```sql
-- Cost distribution
SELECT
  operation_type as category,
  SUM(cost_usd) as value
FROM api_costs
WHERE timestamp >= CURRENT_DATE - INTERVAL '30 days'
GROUP BY operation_type;
```

### Market Comparison (Bar Chart)

```sql
-- Cost per market
SELECT
  m.code as market,
  SUM(ac.cost_usd) as cost
FROM api_costs ac
JOIN markets m ON m.id = ac.market_id
WHERE ac.timestamp >= CURRENT_DATE - INTERVAL '30 days'
GROUP BY m.code
ORDER BY cost DESC;
```

---

## Recommended Monitoring Routine

### Daily (2 minutes)
```sql
-- Quick daily check
SELECT
  SUM(cost_usd) as today,
  (SELECT SUM(cost_usd) FROM api_costs
   WHERE DATE(timestamp) = CURRENT_DATE - 1) as yesterday,
  COUNT(*) as api_calls
FROM api_costs
WHERE DATE(timestamp) = CURRENT_DATE;
```

### Weekly (10 minutes)
```sql
-- Weekly review
SELECT
  DATE_TRUNC('week', timestamp) as week,
  SUM(cost_usd) as cost,
  COUNT(*) as calls,
  COUNT(DISTINCT workflow_name) as workflows
FROM api_costs
WHERE timestamp >= CURRENT_DATE - INTERVAL '4 weeks'
GROUP BY week
ORDER BY week DESC;
```

### Monthly (30 minutes)
- Run all cost analysis queries
- Review expensive runs
- Check budget projections
- Identify optimization opportunities
- Update forecasts

---

## Cost Alerts Setup

### Supabase Functions (Advanced)

Create a Supabase function that runs daily:

```sql
CREATE OR REPLACE FUNCTION check_budget_alert()
RETURNS void AS $$
DECLARE
  daily_budget DECIMAL := 5.00;
  monthly_budget DECIMAL := 100.00;
  today_cost DECIMAL;
  month_cost DECIMAL;
BEGIN
  -- Get costs
  SELECT COALESCE(SUM(cost_usd), 0) INTO today_cost
  FROM api_costs
  WHERE DATE(timestamp) = CURRENT_DATE;

  SELECT COALESCE(SUM(cost_usd), 0) INTO month_cost
  FROM api_costs
  WHERE timestamp >= DATE_TRUNC('month', CURRENT_DATE);

  -- Send alerts (via webhook, email, etc.)
  IF today_cost > daily_budget THEN
    -- Trigger alert
    RAISE NOTICE 'Daily budget exceeded: %', today_cost;
  END IF;

  IF month_cost > monthly_budget * 0.9 THEN
    -- Trigger alert
    RAISE NOTICE 'Monthly budget at 90%%: %', month_cost;
  END IF;
END;
$$ LANGUAGE plpgsql;
```

---

**Last Updated:** November 8, 2025
**Version:** 1.0
