# Supabase Integration Guide

## Overview

This document explains how to integrate Supabase as the production database for the Indie Campers SEO Intelligence system.

## Why Supabase?

- **Performance**: 10-100x faster than Google Sheets (queries in milliseconds)
- **Scalability**: Handles millions of rows vs 10K limit in Sheets
- **Data Integrity**: Proper relationships, foreign keys, and constraints
- **Cost**: FREE tier sufficient for 1+ years of data
- **Production-Ready**: Real database with proper backups and security

## Quick Start

### 1. Create Supabase Project

```bash
# Go to https://supabase.com
# Create new project
# Choose region: Europe (for GDPR/latency)
# Note your project URL and service role key
```

### 2. Run Schema Migration

1. Open Supabase Dashboard → SQL Editor
2. Copy contents of `config/supabase_schema.sql`
3. Click "Run" to create all tables and views

### 3. Configure n8n

```yaml
# In n8n: Credentials → Add Credential → Supabase

Host: https://your-project.supabase.co
Service Role Secret: your_service_role_key_here
```

### 4. Import Workflow

1. In n8n, go to Workflows → Import from File
2. Select `workflows/Authority_Collector_Supabase.json`
3. Update credential IDs in the workflow
4. Activate the workflow

## Database Schema

### Tables

1. **markets** - Market/country configurations
2. **daily_metrics** - Daily SEO metrics per market
3. **api_costs** - API usage tracking

### Views

1. **latest_metrics** - Most recent metrics per market

## Key Features

- ✅ Automatic UUID primary keys
- ✅ Foreign key relationships
- ✅ Data validation with constraints
- ✅ Automatic timestamps (created_at, updated_at)
- ✅ Upsert support (no duplicates)
- ✅ Fast queries with indexes

## Cost Estimate

**Free Tier:** 500MB database, sufficient for 30+ years at current scale

**Projected Usage:**
- Year 1: ~7 MB
- Year 5: ~16 MB

## GDPR Compliance

**Simple compliance:** No personal data collected. Tracking only:
- Domain metrics (public information)
- SEO rankings (public information)
- Backlinks (public information)

**Best Practice:** Delete old detailed data after 2 years (aggregate metrics kept forever)

## Monitoring

```sql
-- View database size
SELECT pg_size_pretty(pg_database_size(current_database()));

-- View latest metrics
SELECT * FROM latest_metrics;

-- View API costs
SELECT 
  DATE_TRUNC('month', timestamp) as month,
  SUM(cost_usd) as total_cost
FROM api_costs
GROUP BY month
ORDER BY month DESC;
```

## Support

- Supabase Docs: https://supabase.com/docs
- n8n Supabase Node: https://docs.n8n.io/integrations/builtin/app-nodes/n8n-nodes-base.supabase/

## Version History

- **v1.0** (Oct 26, 2025) - Initial Supabase integration