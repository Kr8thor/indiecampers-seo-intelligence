# Google Sheets Schemas

## 📋 Overview

The workflow creates 8 tabs in your Google Sheet, each serving a specific purpose in the SEO intelligence pipeline.

---

## Tab 1: Snapshot_Target

**Purpose:** Daily snapshot of IndieCampers' current keyword rankings

| Column | Type | Description | Example |
|--------|------|-------------|-------|
| date | Date | Snapshot date | 2025-10-26 |
| market | String | Market code | PT |
| device | String | Device type | desktop |
| keyword | String | Search query | van hire lisbon |
| rank_absolute | Integer | Current position | 3 |
| search_volume | Integer | Monthly searches | 2400 |
| keyword_difficulty | Integer | SEO difficulty (0-100) | 38 |
| cpc | Decimal | Cost per click (USD) | 3.25 |
| competition | Decimal | PPC competition (0-1) | 0.72 |
| url | URL | Ranking page | https://indiecampers.com/... |
| serp_features | Array | Present features | [featured_snippet, faqs] |
| estimated_traffic | Integer | Monthly visits | 840 |
| ic_traffic_value | Decimal | Traffic value (USD) | 2730.00 |

**Indexes:** date + market + device + keyword (unique)

**Update Frequency:** Daily

**Sample Query:**
```sql
SELECT keyword, rank_absolute, search_volume
FROM Snapshot_Target
WHERE market = 'PT' AND device = 'desktop' AND rank_absolute <= 10
ORDER BY search_volume DESC
LIMIT 20;
```

---

## Tab 2: Competitors_Raw

**Purpose:** All discovered competitors before filtering

| Column | Type | Description | Example |
|--------|------|-------------|-------|
| date | Date | Discovery date | 2025-10-26 |
| market | String | Market code | PT |
| device | String | Device type | desktop |
| competitor_domain | String | Domain name | campingcar.pt |
| overlap_score | Decimal | Keyword overlap (0-1) | 0.68 |
| discovery_method | String | How found | labs_competitors |
| common_keywords | Integer | Shared keywords | 342 |
| competitor_visibility | Decimal | Estimated visibility | 12500 |

**Indexes:** date + market + device + competitor_domain

**Update Frequency:** Daily

---

## Tab 3: Competitors_Selected

**Purpose:** Top 20 competitors per market/device for detailed analysis

| Column | Type | Description | Example |
|--------|------|-------------|-------|
| date | Date | Selection date | 2025-10-26 |
| market | String | Market code | PT |
| device | String | Device type | desktop |
| rank | Integer | Selection rank (1-20) | 1 |
| competitor_domain | String | Domain name | campingcar.pt |
| overlap_score | Decimal | Keyword overlap | 0.68 |
| domain_rating | Integer | Authority (0-100) | 52 |
| referring_domains | Integer | Backlink profile | 1250 |
| organic_keywords | Integer | Ranked keywords | 4500 |
| estimated_traffic | Integer | Monthly visitors | 25000 |
| competitive_strength | Decimal | Combined metric | 0.75 |

**Indexes:** date + market + device + rank

**Update Frequency:** Daily

**Note:** Only these competitors are harvested for keywords (cost optimization)

---

## Tab 4: Competitor_Keywords_Raw

**Purpose:** All keywords harvested from selected competitors

| Column | Type | Description | Example |
|--------|------|-------------|-------|
| date | Date | Harvest date | 2025-10-26 |
| market | String | Market code | PT |
| device | String | Device type | desktop |
| competitor_domain | String | Source domain | campingcar.pt |
| keyword | String | Search query | aluguer autocaravana portugal |
| competitor_rank | Integer | Their position | 2 |
| search_volume | Integer | Monthly searches | 1800 |
| keyword_difficulty | Integer | SEO difficulty | 42 |
| cpc | Decimal | CPC value | 4.15 |
| serp_features | Array | SERP features | [sitelinks, faqs] |
| competitor_url | URL | Ranking page | https://campingcar.pt/... |

**Indexes:** date + market + device + competitor_domain + keyword

**Update Frequency:** Daily

**Volume:** ~20,000-50,000 rows per run

---

## Tab 5: Keyword_Gaps_Scored

**Purpose:** Gap analysis with opportunity scores for prioritization

| Column | Type | Description | Example |
|--------|------|-------------|-------|
| date | Date | Analysis date | 2025-10-26 |
| market | String | Market code | PT |
| device | String | Device type | desktop |
| keyword | String | Gap keyword | motorhome rental portugal |
| our_rank | Integer | Our position (null = gap) | null |
| best_competitor | String | Top competitor | campingcar.pt |
| competitor_rank | Integer | Their position | 3 |
| search_volume | Integer | Monthly searches | 2100 |
| keyword_difficulty | Integer | Difficulty | 35 |
| cpc | Decimal | CPC value | 5.20 |
| click_potential | Decimal | CTR estimate | 0.42 |
| serp_feature_score | Decimal | Feature boost | 0.25 |
| commercial_intent | Decimal | Intent score (0-1) | 0.85 |
| competitor_strength | Decimal | Authority penalty | 0.52 |
| **ic_opportunity_score** | **Decimal** | **Final score (0-100)** | **78.5** |
| gap_type | String | Classification | high_value_transactional |
| recommended_action | String | Next step | create_landing_page |

**Indexes:** date + market + device + keyword

**Update Frequency:** Daily

**Key Metric:** `ic_opportunity_score` (sort DESC for priorities)

**Sample Query:**
```sql
SELECT keyword, ic_opportunity_score, search_volume, keyword_difficulty
FROM Keyword_Gaps_Scored
WHERE market = 'PT' 
  AND device = 'desktop' 
  AND ic_opportunity_score >= 75
  AND keyword_difficulty <= 45
ORDER BY ic_opportunity_score DESC
LIMIT 50;
```

---

## Tab 6: Clusters

**Purpose:** Keyword groups for efficient content planning

| Column | Type | Description | Example |
|--------|------|-------------|-------|
| date | Date | Clustering date | 2025-10-26 |
| market | String | Market code | PT |
| device | String | Device type | desktop |
| cluster_id | String | Unique ID | PT_desktop_cluster_042 |
| cluster_head | String | Primary keyword | van hire portugal |
| cluster_members | Array | Related keywords | ["rent van portugal", "campervan portugal", ...] |
| member_count | Integer | Keywords in cluster | 18 |
| search_intent | String | Intent type | transactional |
| total_volume | Integer | Combined volume | 8500 |
| avg_difficulty | Decimal | Average KD | 38.5 |
| max_opportunity_score | Decimal | Best score in cluster | 82.0 |
| serp_overlap_ratio | Decimal | URL similarity | 0.67 |
| recommended_content_type | String | Format suggestion | landing_page |

**Indexes:** date + market + device + cluster_id

**Update Frequency:** Daily

**Use Case:** One content piece targets entire cluster

---

## Tab 7: Content_Briefs

**Purpose:** AI-ready content templates for writers

| Column | Type | Description | Example |
|--------|------|-------------|-------|
| date | Date | Brief creation date | 2025-10-26 |
| market | String | Market code | PT |
| device | String | Device type | desktop |
| cluster_id | String | Source cluster | PT_desktop_cluster_042 |
| target_keyword | String | Primary keyword | van hire portugal |
| h1_title | String | Page title | Van Hire in Portugal: Best Deals 2025 |
| meta_title | String | SEO title (≤60 chars) | Van Hire Portugal | From €45/day | Book Now |
| meta_description | String | SEO description (≤155) | Rent a van in Portugal from €45/day. Free cancellation... |
| slug | String | URL slug | /van-hire-portugal |
| h2_outline | Array | Main sections | ["Why Rent a Van in Portugal", "Top Routes"...] |
| h3_talking_points | JSON | Detailed points | {"Why Rent...": ["point1", "point2"]} |
| faq_questions | Array | PAA questions | ["How much does van hire cost?", ...] |
| faq_answers | Array | Suggested answers | ["Prices start from €45...", ...] |
| internal_links | Array | Link targets | ["/destinations/portugal", ...] |
| external_references | Array | Authority sites | ["visitportugal.com", ...] |
| structured_data_hints | JSON | Schema.org | {"type": "RentalCarReservation", ...} |
| image_suggestions | Array | Visual needs | ["van on beach", "map of portugal"] |
| word_count_target | Integer | Recommended length | 1800 |
| content_brief_markdown | Text | Full brief | # Van Hire Portugal\n\n## Introduction\n... |

**Indexes:** date + market + device + cluster_id

**Update Frequency:** Daily

**Use Case:** Copy `content_brief_markdown` to CMS/doc for writers

---

## Tab 8: Run_Log

**Purpose:** Execution history and debugging

| Column | Type | Description | Example |
|--------|------|-------------|-------|
| run_id | String | Unique execution ID | run_20251026_070245 |
| start_time | Timestamp | Execution start | 2025-10-26 07:02:45 |
| end_time | Timestamp | Execution end | 2025-10-26 07:38:12 |
| duration_seconds | Integer | Total runtime | 2127 |
| markets_processed | Array | Markets completed | ["PT", "ES", "FR"] |
| total_api_calls | Integer | DataForSEO calls | 485 |
| api_cost_usd | Decimal | Total cost | 15.80 |
| keywords_harvested | Integer | New keywords | 24500 |
| gaps_identified | Integer | Opportunity count | 3200 |
| clusters_created | Integer | Clusters formed | 156 |
| briefs_generated | Integer | Content briefs | 42 |
| errors_count | Integer | Error count | 0 |
| throttle_events | Integer | Rate limit hits | 3 |
| status | String | Run result | success |
| error_log | Text | Error details | null |
| settings_snapshot | JSON | Config used | {...} |

**Indexes:** run_id (primary), start_time DESC

**Update Frequency:** After each execution

**Use Case:** Monitor performance, debug issues, track costs

---

## 📊 Data Relationships

```
Snapshot_Target
    ↓
    ├─────→ Competitors_Raw
    │           ↓
    │       Competitors_Selected
    │           ↓
    │       Competitor_Keywords_Raw
    │           ↓
    └─────────→ Keyword_Gaps_Scored
                    ↓
                Clusters
                    ↓
                Content_Briefs
```

---

## 🛠️ Sheet Setup

**Automatic Creation:**
The workflow creates tabs automatically on first run.

**Manual Creation (Optional):**
1. Create new Google Sheet
2. Create 8 tabs with exact names above
3. Add column headers (first row)
4. Share with service account email

**Formatting Tips:**
- Freeze first row (headers)
- Apply filters to all columns
- Format date columns as `YYYY-MM-DD`
- Format decimals to 2 places
- Use conditional formatting for `ic_opportunity_score` (color scale)

---

## 💻 Sample Queries

### Top Opportunities (This Week)
```sql
SELECT keyword, ic_opportunity_score, search_volume, keyword_difficulty
FROM Keyword_Gaps_Scored
WHERE date >= DATE_SUB(CURRENT_DATE(), INTERVAL 7 DAY)
  AND market = 'PT'
  AND ic_opportunity_score >= 70
ORDER BY ic_opportunity_score DESC
LIMIT 20;
```

### Competitor Analysis
```sql
SELECT 
  competitor_domain,
  COUNT(DISTINCT keyword) as keyword_count,
  AVG(competitor_rank) as avg_rank,
  SUM(search_volume) as total_volume
FROM Competitor_Keywords_Raw
WHERE market = 'PT' AND date = CURRENT_DATE()
GROUP BY competitor_domain
ORDER BY total_volume DESC
LIMIT 10;
```

### Content Brief Pipeline
```sql
SELECT 
  target_keyword,
  word_count_target,
  LENGTH(faq_questions) as faq_count,
  cluster_id
FROM Content_Briefs
WHERE date = CURRENT_DATE()
  AND market = 'PT'
ORDER BY target_keyword;
```

---

**Next:** [Testing Instructions](TESTING.md)