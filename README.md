# IndieCampers SEO Intelligence Pipeline

**Production-grade n8n workflow using DataForSEO for automated SEO intelligence, competitor analysis, and content strategy**

> 🔒 **PRIVATE REPOSITORY** - This repository contains proprietary SEO strategies and business intelligence. Ensure repository remains private at all times. See [REPOSITORY_PRIVACY.md](REPOSITORY_PRIVACY.md) for details.

---

## 📋 Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Architecture](#architecture)
- [Quick Start](#quick-start)
- [Setup Guide](#setup-guide)
- [Google Sheets Schemas](#google-sheets-schemas)
- [Testing](#testing)
- [Troubleshooting](#troubleshooting)

---

## 👁️ Overview

This workflow automates comprehensive SEO intelligence gathering for IndieCampers across multiple markets and devices. It:

1. **Discovers competitors** automatically using DataForSEO Labs API
2. **Harvests keyword opportunities** from competitors' top rankings
3. **Performs gap analysis** to identify where competitors rank but you don't
4. **Calculates opportunity scores** based on volume, difficulty, commercial intent, and SERP features
5. **Clusters keywords** using similarity algorithms and SERP overlap
6. **Generates content briefs** with AI-ready templates
7. **Monitors changes** and sends Slack alerts for significant ranking shifts
8. **Publishes to Google Sheets** with clean, actionable data

### Key Statistics
- **Nodes:** 42 (modular, well-documented)
- **API Calls:** ~200-500 per run (optimized with batching)
- **Execution Time:** 15-45 minutes (depending on markets)
- **Data Output:** 6 Google Sheets tabs with structured data

---

## ✨ Features

### 🎯 Core Capabilities

- ✅ **Multi-Market Support:** PT, ES, FR, DE, UK (expandable)
- ✅ **Device-Specific Analysis:** Desktop + Mobile
- ✅ **Zero HTTP Requests:** Uses only official DataForSEO n8n nodes
- ✅ **Rate Limit Handling:** Exponential backoff with retry logic
- ✅ **Pagination Support:** Handles large datasets (1000+ keywords)
- ✅ **Deduplication:** Prevents duplicate entries across runs

### 🔍 Data Collection

**DataForSEO APIs Used:**
- Labs API: Keywords for Site, Domain Competitors, Related Keywords
- SERP API: Google Organic (Live), People Also Ask
- Backlinks API: Summary, Referring Domains
- Rank Tracker API: Create/Get Tasks (optional monitoring)

### 🧠 Intelligence Layer

- **Opportunity Scoring:** Multi-factor algorithm considering:
  - Search volume (35%)
  - Click potential (25%)
  - SERP features (15%)
  - Keyword difficulty (15%)
  - Commercial intent (10%)
  - Competitor strength penalty (20%)

- **Keyword Clustering:** Groups related keywords by:
  - String similarity (Jaccard/token set ratio)
  - Common n-grams
  - SERP overlap (≥ 4/10 URLs)

- **Search Intent Mapping:** Classifies queries as:
  - Informational (blog content)
  - Transactional (booking pages)
  - Navigational (brand searches)
  - Mixed (hybrid approach)

### 🚨 Monitoring & Alerts

- **Anomaly Detection:** Flags significant changes:
  - Competitor surge: +10 positions or +20% visibility
  - New high-value gaps: OpportunityScore > 75

- **Slack Integration:** Real-time alerts with:
  - Market/device context
  - Change magnitude and direction
  - Top affected keywords
  - Direct link to Google Sheets

---

## 🏛️ Architecture

### High-Level Flow

```
┌──────────────────┐
│  Global Settings  │
│  (Configure Here) │
└────────┬─────────┘
         │
         │
┌────────┴─────────┐
│ Schedule Trigger  │
│  (Daily 07:00)    │
└────────┬─────────┘
         │
    ┌────┴────┐
    │  Market ×  │
    │   Device   │
    │   Matrix   │
    └────┬────┘
         │
    ┌────┴─────────────────────────────────────────────┐
    │                    LOOP OVER MARKETS                   │
    │  (PT_desktop, PT_mobile, ES_desktop, ES_mobile...)    │
    └────┬─────────────────────────────────────────────┘
         │
         ├──────────────────────────────────┐
         │  🎯 Phase 1: Target Snapshot           │
         │  - Get our ranked keywords             │
         │  - Calculate baseline metrics          │
         │  - Save to Snapshot_Target tab         │
         └────────────────┬──────────────────┘
                   │
         ├─────────┴────────────────────────┐
         │  🔍 Phase 2: Competitor Discovery       │
         │  - Find overlapping domains            │
         │  - Analyze SERP competitors            │
         │  - Rank by overlap/authority           │
         │  - Save to Competitors tabs            │
         └────────────────┬──────────────────┘
                   │
         ├─────────┴────────────────────────┐
         │  🌾 Phase 3: Harvest Keywords          │
         │  - Loop through competitors            │
         │  - Get their top keywords              │
         │  - Fetch backlink authority            │
         │  - Rate limit handling                 │
         │  - Save to Competitor_Keywords_Raw     │
         └────────────────┬──────────────────┘
                   │
         ├─────────┴────────────────────────┐
         │  📊 Phase 4: Gap Analysis             │
         │  - Join target + competitor data       │
         │  - Identify keyword gaps               │
         │  - Calculate OpportunityScore          │
         │  - Save to Keyword_Gaps_Scored         │
         └────────────────┬──────────────────┘
                   │
         ├─────────┴────────────────────────┐
         │  🧩 Phase 5: Clustering              │
         │  - Group similar keywords              │
         │  - Map search intent                   │
         │  - Select cluster heads                │
         │  - Save to Clusters tab                │
         └────────────────┬──────────────────┘
                   │
         ├─────────┴────────────────────────┐
         │  📝 Phase 6: Content Briefs          │
         │  - Generate H1/H2/H3 outlines          │
         │  - Extract PAA questions               │
         │  - Suggest internal linking            │
         │  - Provide structured data hints       │
         │  - Save to Content_Briefs tab          │
         └────────────────┬──────────────────┘
                   │
         ├─────────┴────────────────────────┐
         │  📡 Phase 7: Monitoring & Alerts    │
         │  - Check for ranking changes           │
         │  - Detect competitor surges            │
         │  - Send Slack alerts                   │
         └────────────────┬──────────────────┘
                   │
         ├─────────┴────────────────────────┐
         │  ✅ Phase 8: QA & Logging            │
         │  - Run data validation                 │
         │  - Log run statistics                  │
         │  - Update Run_Log tab                  │
         └─────────────────────────────────────────┘
```

---

## 🚀 Quick Start

### Prerequisites

- **n8n instance** (cloud or self-hosted)
- **DataForSEO API account** (get from dataforseo.com)
- **Google Sheets API access** (via service account)
- **Slack workspace** (for alerts, optional)

### Installation (5 minutes)

1. **Clone this repository:**
   ```bash
   git clone https://github.com/Kr8thor/indiecampers-seo-intelligence.git
   cd indiecampers-seo-intelligence
   ```

2. **Import workflow to n8n:**
   - Open n8n
   - Go to Workflows → Add Workflow → Import from File
   - Select `workflows/seo-intelligence-pipeline.json`

3. **Configure credentials:**
   - See [Setup Guide](docs/SETUP.md) for detailed instructions

4. **Update Global Settings:**
   - Open the workflow
   - Edit the "Global Settings" node
   - Set your `SHEET_ID`
   - Adjust markets/thresholds as needed

5. **Test with dry run:**
   ```
   Set MARKETS = [{"country":"PT","language":"pt-PT","location":"Lisbon","location_code":2620}]
   Set MAX_COMPETITORS_PER_MARKET = 5
   Set TOP_KEYWORDS_PER_DOMAIN = 200
   ```
   Execute manually and verify outputs

6. **Activate schedule:**
   - Set workflow to Active
   - Runs daily at 07:00 UTC

---

## 🔧 Setup Guide

See [docs/SETUP.md](docs/SETUP.md) for:
- DataForSEO API credentials configuration
- Google Sheets service account setup
- Slack webhook configuration
- Environment variables

---

## 📄 Google Sheets Schemas

See [docs/GOOGLE_SHEETS_SCHEMAS.md](docs/GOOGLE_SHEETS_SCHEMAS.md) for complete schemas.

**Tabs Overview:**

1. **Snapshot_Target:** Our current rankings (daily updates)
2. **Competitors_Raw:** All discovered competitors
3. **Competitors_Selected:** Top 20 competitors by overlap
4. **Competitor_Keywords_Raw:** All competitor keywords harvested
5. **Keyword_Gaps_Scored:** Gap analysis with opportunity scores
6. **Clusters:** Keyword groups with head terms
7. **Content_Briefs:** AI-ready content templates
8. **Run_Log:** Execution history and statistics

---

## 🧪 Testing

See [docs/TESTING.md](docs/TESTING.md) for:
- Dry run instructions
- Unit testing individual phases
- Validation checklists
- Troubleshooting common errors

---

## 💰 Cost Estimation

### Per Run (5 markets × 2 devices = 10 combinations)

| API Component | Calls | Cost |
|---------------|----------|------|
| Target Keywords | 10 | $0.50 |
| Competitor Discovery | 10 | $0.30 |
| Competitor Keywords | 200 | $10.00 |
| Backlink Summaries | 200 | $2.00 |
| SERP Queries | 50 | $2.50 |
| **Total per run** | **470** | **~$15.30** |

**Monthly:** ~$460 (30 days) + buffer = **$500-600/month**

### Optimization Tips:
- Reduce markets (test with 1-2 first)
- Lower MAX_COMPETITORS_PER_MARKET (20 → 10)
- Decrease TOP_KEYWORDS_PER_DOMAIN (1000 → 500)
- Run less frequently (daily → weekly)

---

## 🛠️ Troubleshooting

### Common Issues

**1. "SHEET_ID not configured" error**
- Edit Global Settings node
- Replace `YOUR_GOOGLE_SHEET_ID` with actual Sheet ID

**2. "DataForSEO API rate limit exceeded"**
- Workflow includes exponential backoff
- Reduce batch size in Loop Over Markets node
- Add delay between competitor iterations

**3. "Google Sheets permission denied"**
- Verify service account has Editor access
- Check API is enabled in Google Cloud Console
- Ensure Sheet ID is correct

**4. "No competitors found"**
- Check if TARGET_DOMAIN has ranked keywords
- Lower RANK_THRESHOLD (20 → 30)
- Verify market/location codes are correct

**5. "Workflow timeout"**
- Reduce number of markets in one run
- Split into separate workflows per market
- Increase n8n execution timeout setting

---

## 📚 Documentation

- [Setup Guide](docs/SETUP.md)
- [Google Sheets Schemas](docs/GOOGLE_SHEETS_SCHEMAS.md)
- [Testing Instructions](docs/TESTING.md)
- [Alert Examples](docs/ALERTS.md)

---

## 🤝 Contributing

Contributions welcome! Please:
1. Fork the repository
2. Create a feature branch
3. Test thoroughly with dry runs
4. Submit PR with clear description

---

## 📜 License

MIT License - See [LICENSE](LICENSE)

---

## 👥 Support

- **Issues:** [GitHub Issues](https://github.com/Kr8thor/indiecampers-seo-intelligence/issues)
- **Discussions:** [GitHub Discussions](https://github.com/Kr8thor/indiecampers-seo-intelligence/discussions)
- **DataForSEO Docs:** [dataforseo.com/apis](https://dataforseo.com/apis)
- **n8n Community:** [community.n8n.io](https://community.n8n.io)

---

**Built with ❤️ for IndieCampers SEO Team**

*Last Updated: October 26, 2025*