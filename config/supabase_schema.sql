-- ============================================================================
-- INDIE CAMPERS SEO INTELLIGENCE - SUPABASE DATABASE SCHEMA
-- ============================================================================
-- Version: 1.0
-- Created: October 26, 2025
-- Description: Complete database schema for Authority Collector workflow
-- ============================================================================

-- Enable UUID extension for primary keys
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================================================
-- TABLE 1: MARKETS (Reference Data)
-- ============================================================================
-- Stores market/country configurations for multi-region SEO tracking

CREATE TABLE IF NOT EXISTS markets (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  code VARCHAR(2) UNIQUE NOT NULL, -- PT, ES, FR, DE, UK
  name VARCHAR(50) NOT NULL,
  location_code INTEGER NOT NULL, -- DataForSEO location code
  language_name VARCHAR(20) NOT NULL,
  domain VARCHAR(100) NOT NULL,
  active BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT NOW()
);

-- Seed market data
INSERT INTO markets (code, name, location_code, language_name, domain) VALUES
  ('PT', 'Portugal', 2620, 'Portuguese', 'indie-campers.pt'),
  ('ES', 'Spain', 2724, 'Spanish', 'indie-campers.es'),
  ('FR', 'France', 2250, 'French', 'indie-campers.fr'),
  ('DE', 'Germany', 2276, 'German', 'indie-campers.de'),
  ('UK', 'United Kingdom', 2826, 'English', 'indie-campers.co.uk')
ON CONFLICT (code) DO NOTHING;

COMMENT ON TABLE markets IS 'Market/country configurations for multi-region SEO tracking';
COMMENT ON COLUMN markets.location_code IS 'DataForSEO location code for API queries';
COMMENT ON COLUMN markets.domain IS 'Target domain for this market';

-- ============================================================================
-- TABLE 2: DAILY_METRICS (Authority & Rankings)
-- ============================================================================
-- Stores daily SEO metrics collected from DataForSEO

CREATE TABLE IF NOT EXISTS daily_metrics (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  market_id UUID REFERENCES markets(id) ON DELETE CASCADE NOT NULL,
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
  
  -- Ensure one entry per market per day
  UNIQUE(market_id, date)
);

-- Indexes for fast queries
CREATE INDEX IF NOT EXISTS idx_daily_metrics_market_date 
  ON daily_metrics(market_id, date DESC);
CREATE INDEX IF NOT EXISTS idx_daily_metrics_date 
  ON daily_metrics(date DESC);

COMMENT ON TABLE daily_metrics IS 'Daily SEO metrics: authority, rankings, traffic estimates';
COMMENT ON COLUMN daily_metrics.domain_rating IS 'Authority score (0-100) from DataForSEO';
COMMENT ON COLUMN daily_metrics.domain_rating_delta IS 'Change from previous day';
COMMENT ON COLUMN daily_metrics.average_ranking IS 'Average SERP position across all keywords';

-- ============================================================================
-- TABLE 3: BACKLINKS (Link Quality Details)
-- ============================================================================
-- Stores detailed backlink data for quality analysis

CREATE TABLE IF NOT EXISTS backlinks (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  market_id UUID REFERENCES markets(id) ON DELETE CASCADE NOT NULL,
  
  -- Link Details
  domain_from VARCHAR(255) NOT NULL,
  domain_from_rank INTEGER CHECK (domain_from_rank >= 0 AND domain_from_rank <= 100),
  url_from TEXT,
  url_to TEXT,
  anchor TEXT,
  dofollow BOOLEAN DEFAULT true,
  
  -- Tracking
  first_seen DATE NOT NULL,
  last_checked DATE NOT NULL,
  status VARCHAR(20) DEFAULT 'active', -- active, lost, broken
  
  -- Metadata
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  
  -- Prevent duplicates
  UNIQUE(market_id, domain_from, url_from, url_to)
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_backlinks_market 
  ON backlinks(market_id, last_checked DESC);
CREATE INDEX IF NOT EXISTS idx_backlinks_domain_rank 
  ON backlinks(domain_from_rank DESC);
CREATE INDEX IF NOT EXISTS idx_backlinks_status 
  ON backlinks(status, market_id);

COMMENT ON TABLE backlinks IS 'Detailed backlink inventory for link quality analysis';
COMMENT ON COLUMN backlinks.domain_from_rank IS 'Authority of referring domain (0-100)';
COMMENT ON COLUMN backlinks.status IS 'active = live, lost = removed, broken = 404';

-- ============================================================================
-- TABLE 4: TECHNICAL_HEALTH (Weekly Audits)
-- ============================================================================
-- Stores technical SEO audit results (on-page issues, Core Web Vitals)

CREATE TABLE IF NOT EXISTS technical_health (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  market_id UUID REFERENCES markets(id) ON DELETE CASCADE NOT NULL,
  audit_date DATE NOT NULL,
  
  -- Crawl Stats
  pages_crawled INTEGER,
  technical_health_score DECIMAL(5,2) CHECK (technical_health_score >= 0 AND technical_health_score <= 100),
  
  -- Issues
  broken_links INTEGER,
  duplicate_titles INTEGER,
  duplicate_descriptions INTEGER,
  duplicate_content INTEGER,
  broken_resources INTEGER,
  orphan_pages INTEGER,
  links_4xx INTEGER,
  links_5xx INTEGER,
  
  -- Core Web Vitals
  core_web_vitals_score DECIMAL(5,2) CHECK (core_web_vitals_score >= 0 AND core_web_vitals_score <= 100),
  lcp_value INTEGER, -- Largest Contentful Paint (ms)
  lcp_pass BOOLEAN,
  cls_value DECIMAL(6,3), -- Cumulative Layout Shift
  cls_pass BOOLEAN,
  tbt_value INTEGER, -- Total Blocking Time (ms)
  tbt_pass BOOLEAN,
  
  -- Critical Issues Summary
  critical_issues TEXT,
  has_critical_issues BOOLEAN DEFAULT false,
  
  -- Metadata
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  
  UNIQUE(market_id, audit_date)
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_technical_market_date 
  ON technical_health(market_id, audit_date DESC);
CREATE INDEX IF NOT EXISTS idx_technical_critical 
  ON technical_health(has_critical_issues, market_id);

COMMENT ON TABLE technical_health IS 'Weekly technical SEO audits: on-page issues, Core Web Vitals';
COMMENT ON COLUMN technical_health.technical_health_score IS 'Overall health score (0-100)';
COMMENT ON COLUMN technical_health.lcp_value IS 'Largest Contentful Paint in milliseconds';

-- ============================================================================
-- TABLE 5: API_COSTS (Usage Tracking)
-- ============================================================================
-- Tracks API costs for budget monitoring

CREATE TABLE IF NOT EXISTS api_costs (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  timestamp TIMESTAMP DEFAULT NOW(),
  
  -- Context
  workflow_name VARCHAR(100),
  market_id UUID REFERENCES markets(id) ON DELETE CASCADE,
  operation_type VARCHAR(50), -- 'backlinks_summary', 'ranked_keywords', etc.
  
  -- Cost Details
  cost_usd DECIMAL(10,4),
  api_provider VARCHAR(50), -- 'DataForSEO', 'Claude', 'Google'
  
  -- Optional: Request/Response Metadata
  request_payload JSONB,
  response_metadata JSONB
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_api_costs_timestamp 
  ON api_costs(timestamp DESC);
CREATE INDEX IF NOT EXISTS idx_api_costs_market 
  ON api_costs(market_id, timestamp DESC);
CREATE INDEX IF NOT EXISTS idx_api_costs_workflow 
  ON api_costs(workflow_name, timestamp DESC);

COMMENT ON TABLE api_costs IS 'API usage tracking for cost monitoring and budget alerts';
COMMENT ON COLUMN api_costs.cost_usd IS 'Cost in USD (4 decimal places for precision)';

-- ============================================================================
-- TABLE 6: CONVERSATION_HISTORY (Slack Context)
-- ============================================================================
-- Stores Slack conversation history for AI context

CREATE TABLE IF NOT EXISTS conversation_history (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  
  -- Slack Context
  user_id VARCHAR(50) NOT NULL, -- Slack user ID
  channel_id VARCHAR(50),
  thread_ts VARCHAR(50), -- Thread timestamp for context
  
  -- Question & Response
  question TEXT NOT NULL,
  response TEXT NOT NULL,
  intent VARCHAR(50), -- rankings, backlinks, technical, etc.
  market_code VARCHAR(2),
  
  -- AI Metadata
  claude_model VARCHAR(50),
  tokens_used INTEGER,
  response_time_ms INTEGER,
  
  -- Quality Tracking
  user_rating INTEGER CHECK (user_rating >= 1 AND user_rating <= 5),
  feedback TEXT,
  
  -- Timestamps
  created_at TIMESTAMP DEFAULT NOW()
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_conversation_user 
  ON conversation_history(user_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_conversation_thread 
  ON conversation_history(thread_ts, created_at);
CREATE INDEX IF NOT EXISTS idx_conversation_intent 
  ON conversation_history(intent, created_at DESC);

COMMENT ON TABLE conversation_history IS 'Slack conversation history for AI context and quality tracking';
COMMENT ON COLUMN conversation_history.intent IS 'Detected user intent: rankings, backlinks, technical, etc.';

-- ============================================================================
-- FUNCTIONS & TRIGGERS
-- ============================================================================

-- Auto-update timestamp function
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Apply to tables
CREATE TRIGGER IF NOT EXISTS update_daily_metrics_updated_at 
  BEFORE UPDATE ON daily_metrics
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER IF NOT EXISTS update_backlinks_updated_at 
  BEFORE UPDATE ON backlinks
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER IF NOT EXISTS update_technical_health_updated_at 
  BEFORE UPDATE ON technical_health
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ============================================================================
-- VIEWS FOR EASY QUERYING
-- ============================================================================

-- View: Latest metrics per market
CREATE OR REPLACE VIEW latest_metrics AS
SELECT 
  m.code,
  m.name,
  dm.*
FROM daily_metrics dm
JOIN markets m ON m.id = dm.market_id
WHERE dm.date = (
  SELECT MAX(date) 
  FROM daily_metrics 
  WHERE market_id = dm.market_id
);

COMMENT ON VIEW latest_metrics IS 'Most recent metrics for each market';

-- View: 7-day trends per market
CREATE OR REPLACE VIEW metrics_7day_trend AS
SELECT 
  m.code,
  m.name,
  dm.date,
  dm.domain_rating,
  dm.average_ranking,
  dm.keywords_top_10,
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

COMMENT ON VIEW metrics_7day_trend IS '7-day rolling window with day-over-day changes';

-- View: Monthly cost summary
CREATE OR REPLACE VIEW monthly_cost_summary AS
SELECT 
  DATE_TRUNC('month', timestamp) as month,
  SUM(cost_usd) as total_cost,
  SUM(CASE WHEN api_provider = 'DataForSEO' THEN cost_usd ELSE 0 END) as dataforseo_cost,
  SUM(CASE WHEN api_provider = 'Claude' THEN cost_usd ELSE 0 END) as claude_cost,
  COUNT(*) as total_calls
FROM api_costs
GROUP BY DATE_TRUNC('month', timestamp)
ORDER BY month DESC;

COMMENT ON VIEW monthly_cost_summary IS 'Monthly API costs by provider';

-- View: High-authority backlinks per market
CREATE OR REPLACE VIEW high_authority_backlinks AS
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

COMMENT ON VIEW high_authority_backlinks IS 'Count of high-authority (DR 35+) backlinks per market';

-- ============================================================================
-- COMPLETE! Schema is ready for n8n workflows.
-- ============================================================================
