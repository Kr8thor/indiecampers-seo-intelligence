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
CREATE TABLE IF NOT EXISTS markets (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  code VARCHAR(2) UNIQUE NOT NULL,
  name VARCHAR(50) NOT NULL,
  location_code INTEGER NOT NULL,
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

-- ============================================================================
-- TABLE 2: DAILY_METRICS (Authority & Rankings)
-- ============================================================================
CREATE TABLE IF NOT EXISTS daily_metrics (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  market_id UUID REFERENCES markets(id) ON DELETE CASCADE NOT NULL,
  date DATE NOT NULL,
  domain_rating INTEGER CHECK (domain_rating >= 0 AND domain_rating <= 100),
  domain_rating_delta DECIMAL(5,2),
  total_backlinks INTEGER,
  referring_domains INTEGER,
  dofollow_backlinks INTEGER,
  average_ranking DECIMAL(6,2),
  average_ranking_delta DECIMAL(6,2),
  total_ranked_keywords INTEGER,
  keywords_top_1 INTEGER,
  keywords_top_3 INTEGER,
  keywords_top_10 INTEGER,
  keywords_top_20 INTEGER,
  keywords_top_30 INTEGER,
  estimated_traffic_value DECIMAL(10,2),
  organic_keywords_count INTEGER,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  UNIQUE(market_id, date)
);

CREATE INDEX IF NOT EXISTS idx_daily_metrics_market_date ON daily_metrics(market_id, date DESC);
CREATE INDEX IF NOT EXISTS idx_daily_metrics_date ON daily_metrics(date DESC);

-- ============================================================================
-- TABLE 3: API_COSTS (Usage Tracking)
-- ============================================================================
CREATE TABLE IF NOT EXISTS api_costs (
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

CREATE INDEX IF NOT EXISTS idx_api_costs_timestamp ON api_costs(timestamp DESC);

-- ============================================================================
-- VIEWS FOR EASY QUERYING
-- ============================================================================
CREATE OR REPLACE VIEW latest_metrics AS
SELECT m.code, m.name, dm.*
FROM daily_metrics dm
JOIN markets m ON m.id = dm.market_id
WHERE dm.date = (SELECT MAX(date) FROM daily_metrics WHERE market_id = dm.market_id);