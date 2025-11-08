# Architecture Overview

This document provides visual diagrams and detailed explanations of the IndieCampers SEO Intelligence system architecture.

---

## System Components

```mermaid
graph TB
    subgraph "Automation Layer"
        N8N[n8n Workflows]
        SCHED[Schedule Trigger]
    end

    subgraph "Data Sources"
        DFSEO[DataForSEO API]
        LABS[Labs API]
        SERP[SERP API]
        BL[Backlinks API]
    end

    subgraph "Storage Layer"
        DB[(Supabase PostgreSQL)]
        SHEETS[Google Sheets]
    end

    subgraph "Alerting"
        SLACK[Slack Webhooks]
    end

    SCHED --> N8N
    N8N --> DFSEO
    DFSEO --> LABS
    DFSEO --> SERP
    DFSEO --> BL
    N8N --> DB
    N8N --> SHEETS
    N8N --> SLACK

    style N8N fill:#ff6b6b
    style DB fill:#4ecdc4
    style DFSEO fill:#95e1d3
    style SLACK fill:#f38181
```

---

## Data Flow - Full SEO Intelligence Pipeline

```mermaid
sequenceDiagram
    participant Scheduler
    participant n8n
    participant DataForSEO
    participant Supabase
    participant Sheets
    participant Slack

    Scheduler->>n8n: Trigger Daily (07:00 UTC)

    loop For Each Market×Device
        n8n->>DataForSEO: Get Target Keywords
        DataForSEO-->>n8n: Ranked keywords (200-1000)

        n8n->>DataForSEO: Find Competitors
        DataForSEO-->>n8n: Competitor domains (20)

        loop For Each Competitor
            n8n->>DataForSEO: Get Competitor Keywords
            DataForSEO-->>n8n: Keywords (500-1000)

            n8n->>DataForSEO: Get Backlink Data
            DataForSEO-->>n8n: Authority metrics
        end

        n8n->>n8n: Calculate Gap Analysis
        n8n->>n8n: Score Opportunities
        n8n->>n8n: Cluster Keywords
        n8n->>n8n: Generate Content Briefs

        n8n->>Sheets: Write Results (6 tabs)
        Sheets-->>n8n: Success

        n8n->>n8n: Detect Anomalies

        alt Anomaly Detected
            n8n->>Slack: Send Alert
        end
    end

    n8n->>Sheets: Update Run Log
```

---

## Data Flow - Authority Collector (Lightweight)

```mermaid
sequenceDiagram
    participant Scheduler
    participant n8n
    participant DataForSEO
    participant Supabase
    participant Slack

    Scheduler->>n8n: Trigger Daily (08:00 UTC)
    n8n->>Supabase: Get Active Markets
    Supabase-->>n8n: 5 markets (PT, ES, FR, DE, UK)

    loop For Each Market
        n8n->>DataForSEO: Get Ranked Keywords
        DataForSEO-->>n8n: Keyword data

        n8n->>DataForSEO: Get Backlink Summary
        DataForSEO-->>n8n: Authority metrics

        n8n->>n8n: Calculate Metrics
        Note over n8n: Domain Rating<br/>Avg Ranking<br/>Top 10 Keywords<br/>Backlinks

        n8n->>Supabase: Upsert Daily Metrics
        n8n->>Supabase: Log API Costs

        n8n->>Supabase: Get Previous Day Metrics
        Supabase-->>n8n: Historical data

        n8n->>n8n: Calculate Deltas
        n8n->>n8n: Detect Anomalies

        alt Significant Change
            n8n->>Slack: Send Alert
            Note over Slack: DR changed +5<br/>Ranking improved
        end
    end
```

---

## Workflow Architecture - Full Pipeline

```mermaid
graph LR
    subgraph "Phase 1: Target Snapshot"
        T1[Get Our Keywords]
        T2[Calculate Baseline]
        T3[Save to Snapshot_Target]
    end

    subgraph "Phase 2: Competitor Discovery"
        C1[Find Overlapping Domains]
        C2[Get SERP Competitors]
        C3[Rank by Overlap]
        C4[Save Top 20]
    end

    subgraph "Phase 3: Keyword Harvest"
        H1[Loop Competitors]
        H2[Get Their Keywords]
        H3[Get Backlinks]
        H4[Save Raw Data]
    end

    subgraph "Phase 4: Gap Analysis"
        G1[Join Datasets]
        G2[Identify Gaps]
        G3[Score Opportunities]
        G4[Save Scored Gaps]
    end

    subgraph "Phase 5: Clustering"
        CL1[Group Similar]
        CL2[Map Intent]
        CL3[Select Heads]
        CL4[Save Clusters]
    end

    subgraph "Phase 6: Content Briefs"
        B1[Generate Outlines]
        B2[Extract PAA]
        B3[Suggest Links]
        B4[Save Briefs]
    end

    subgraph "Phase 7: Monitoring"
        M1[Check Changes]
        M2[Detect Surges]
        M3[Send Alerts]
    end

    T1 --> T2 --> T3
    T3 --> C1
    C1 --> C2 --> C3 --> C4
    C4 --> H1 --> H2 --> H3 --> H4
    H4 --> G1 --> G2 --> G3 --> G4
    G4 --> CL1 --> CL2 --> CL3 --> CL4
    CL4 --> B1 --> B2 --> B3 --> B4
    B4 --> M1 --> M2 --> M3

    style T3 fill:#e8f5e9
    style C4 fill:#e3f2fd
    style H4 fill:#fff3e0
    style G4 fill:#fce4ec
    style CL4 fill:#f3e5f5
    style B4 fill:#e0f2f1
    style M3 fill:#ffebee
```

---

## Database Schema - Supabase

```mermaid
erDiagram
    MARKETS ||--o{ DAILY_METRICS : has
    MARKETS ||--o{ BACKLINKS : has
    MARKETS ||--o{ TECHNICAL_HEALTH : has
    MARKETS ||--o{ API_COSTS : has

    MARKETS {
        uuid id PK
        varchar code UK
        varchar name
        int location_code
        varchar language_name
        varchar domain
        boolean active
        timestamp created_at
    }

    DAILY_METRICS {
        uuid id PK
        uuid market_id FK
        date date
        int domain_rating
        decimal domain_rating_delta
        int total_backlinks
        int referring_domains
        decimal average_ranking
        decimal average_ranking_delta
        int keywords_top_10
        timestamp created_at
    }

    BACKLINKS {
        uuid id PK
        uuid market_id FK
        varchar domain_from
        int domain_from_rank
        text url_from
        text url_to
        text anchor
        boolean dofollow
        date first_seen
        date last_checked
        varchar status
    }

    TECHNICAL_HEALTH {
        uuid id PK
        uuid market_id FK
        date audit_date
        int pages_crawled
        decimal technical_health_score
        int broken_links
        int duplicate_titles
        decimal core_web_vitals_score
        boolean has_critical_issues
    }

    API_COSTS {
        uuid id PK
        timestamp timestamp
        varchar workflow_name
        uuid market_id FK
        varchar operation_type
        decimal cost_usd
        varchar api_provider
    }
```

---

## Opportunity Scoring Algorithm

```mermaid
graph TD
    START[Input: Keyword] --> VOL[Normalize Search Volume]
    START --> CTR[Get Click Potential]
    START --> SERP[Check SERP Features]
    START --> KD[Normalize Keyword Difficulty]
    START --> INTENT[Detect Commercial Intent]
    START --> COMP[Calculate Competitor Strength]

    VOL --> W1[× 0.35 weight]
    CTR --> W2[× 0.25 weight]
    SERP --> W3[× 0.15 weight]
    KD --> W4[× 0.15 weight]
    INTENT --> W5[× 0.10 weight]
    COMP --> W6[× -0.20 penalty]

    W1 --> SUM[Sum Components]
    W2 --> SUM
    W3 --> SUM
    W4 --> SUM
    W5 --> SUM
    W6 --> SUM

    SUM --> SCALE[Scale to 0-100]
    SCALE --> SCORE[Opportunity Score]

    style START fill:#e3f2fd
    style SCORE fill:#c8e6c9
    style W6 fill:#ffcdd2
```

**Formula:**
```
OpportunityScore = (
    w1 × normalizedVolume +
    w2 × clickPotential +
    w3 × serpFeatureBoost +
    w4 × (1 - normalizedKD) +
    w5 × commercialIntent -
    w6 × competitorStrength
) × 100
```

**Where:**
- `normalizedVolume` = min(searchVolume / 10000, 1)
- `clickPotential` = baseCTR[rank] × serpPenalty
- `serpFeatureBoost` = 1 if has priority features, else 0
- `normalizedKD` = keywordDifficulty / 100
- `commercialIntent` = 0.8 if transactional, 0.2 otherwise
- `competitorStrength` = (domainRating/100 + rankScore) / 2

---

## Keyword Clustering Process

```mermaid
graph LR
    subgraph "Input"
        KW[Keyword List]
    end

    subgraph "Similarity Analysis"
        TOK[Tokenize]
        JAC[Jaccard Similarity]
        NGRAM[N-gram Overlap]
    end

    subgraph "SERP Analysis"
        GET[Get SERP Results]
        COMP[Compare URLs]
        OVER[Calculate Overlap]
    end

    subgraph "Clustering"
        GRP[Group by Similarity]
        HEAD[Select Head Terms]
        INT[Map Search Intent]
    end

    subgraph "Output"
        CLUST[Keyword Clusters]
    end

    KW --> TOK
    TOK --> JAC
    TOK --> NGRAM

    KW --> GET
    GET --> COMP
    COMP --> OVER

    JAC --> GRP
    NGRAM --> GRP
    OVER --> GRP

    GRP --> HEAD
    HEAD --> INT
    INT --> CLUST

    style KW fill:#e3f2fd
    style CLUST fill:#c8e6c9
```

**Clustering Criteria:**
- Jaccard similarity > 0.6 OR
- N-gram overlap > 50% OR
- SERP URL overlap ≥ 4/10 URLs

---

## Deployment Architecture

### Option 1: n8n Cloud (Recommended for Beginners)

```mermaid
graph TB
    subgraph "n8n Cloud"
        WF[Workflows]
        EXEC[Execution Engine]
        CRED[Credential Store]
    end

    subgraph "External Services"
        DFSEO[DataForSEO API]
        SUP[Supabase Cloud]
        SLACK[Slack]
    end

    subgraph "Users"
        TEAM[Team Members]
        DASH[Dashboard Viewers]
    end

    WF --> EXEC
    CRED --> EXEC
    EXEC --> DFSEO
    EXEC --> SUP
    EXEC --> SLACK

    TEAM --> WF
    DASH --> SUP

    style WF fill:#ff6b6b
    style SUP fill:#4ecdc4
```

**Pros:**
- No infrastructure management
- Built-in security
- Automatic updates
- Easy team collaboration

**Cons:**
- Monthly cost ($20-50)
- Less customization
- Vendor lock-in

---

### Option 2: Self-Hosted (Advanced)

```mermaid
graph TB
    subgraph "Your Server / VPS"
        DOCKER[Docker Container]
        N8N[n8n Instance]
        VOL[Volume Storage]
        NGINX[Reverse Proxy]
    end

    subgraph "External Services"
        DFSEO[DataForSEO API]
        SUP[Supabase Cloud]
        SLACK[Slack]
    end

    subgraph "Security"
        SSL[SSL Certificate]
        AUTH[Basic Auth]
    end

    DOCKER --> N8N
    N8N --> VOL
    NGINX --> N8N
    SSL --> NGINX
    AUTH --> NGINX

    N8N --> DFSEO
    N8N --> SUP
    N8N --> SLACK

    style DOCKER fill:#2496ed
    style N8N fill:#ff6b6b
```

**Pros:**
- Full control
- No monthly SaaS costs
- Custom integrations
- Data sovereignty

**Cons:**
- Requires DevOps skills
- Manual updates
- Backup responsibility
- Security management

---

## Security Architecture

```mermaid
graph TB
    subgraph "Secrets Management"
        ENV[.env File]
        N8N_CRED[n8n Credentials]
        GIT[.gitignore]
    end

    subgraph "Access Control"
        N8N_AUTH[n8n Authentication]
        SUP_RLS[Supabase RLS]
        API_KEY[API Keys]
    end

    subgraph "Monitoring"
        LOGS[Execution Logs]
        AUDIT[Audit Trail]
        ALERTS[Security Alerts]
    end

    subgraph "Protection"
        RATE[Rate Limiting]
        VALID[Input Validation]
        ENCRYPT[Encryption at Rest]
    end

    ENV --> N8N_CRED
    GIT --> ENV

    N8N_AUTH --> N8N_CRED
    SUP_RLS --> API_KEY

    N8N_CRED --> LOGS
    API_KEY --> AUDIT

    RATE --> VALID
    VALID --> ENCRYPT

    style ENV fill:#ffebee
    style N8N_AUTH fill:#e8f5e9
    style LOGS fill:#e3f2fd
    style RATE fill:#fff3e0
```

---

## Scalability Considerations

### Current Limits

| Component | Current | Max (Without Changes) | Bottleneck |
|-----------|---------|----------------------|------------|
| Markets | 5 | 20 | DataForSEO rate limit |
| Competitors/Market | 20 | 50 | Execution time |
| Keywords/Competitor | 1000 | 2000 | API cost |
| Daily Runs | 1 | 4 | API budget |
| Data Storage | 100MB | Unlimited | Supabase free tier |

### Scaling Strategies

**Horizontal Scaling:**
```mermaid
graph LR
    M[Markets] --> W1[Workflow 1: PT + ES]
    M --> W2[Workflow 2: FR + DE]
    M --> W3[Workflow 3: UK]

    W1 --> DB[(Database)]
    W2 --> DB
    W3 --> DB

    style M fill:#e3f2fd
    style DB fill:#c8e6c9
```

**Vertical Scaling:**
- Increase API rate limits (paid plan)
- Use caching for backlink data
- Batch processing for efficiency
- Parallel competitor harvesting

---

## Cost Architecture

```mermaid
graph TD
    subgraph "Fixed Costs (Monthly)"
        N8N_C[n8n Cloud: $20-50]
        SUP_C[Supabase: $0]
        SLACK_C[Slack: $0]
    end

    subgraph "Variable Costs (Per Run)"
        DFSEO_C[DataForSEO: $15-20]
    end

    subgraph "Total Monthly"
        DAILY[Daily Run: $450-600]
        WEEKLY[Weekly Run: $100-150]
        MONTHLY[Monthly Run: $35-70]
    end

    N8N_C --> TOTAL[Total Cost]
    SUP_C --> TOTAL
    SLACK_C --> TOTAL
    DFSEO_C --> TOTAL

    TOTAL --> DAILY
    TOTAL --> WEEKLY
    TOTAL --> MONTHLY

    style DAILY fill:#ffcdd2
    style WEEKLY fill:#fff9c4
    style MONTHLY fill:#c8e6c9
```

**Cost Optimization:**
1. Use Authority Collector for daily monitoring (~$0.60/run)
2. Run full pipeline weekly/monthly only
3. Reduce markets or competitors
4. Implement caching (future enhancement)

---

## Technology Stack

```mermaid
mindmap
  root((SEO Intelligence))
    Automation
      n8n Workflow Engine
      Cron Scheduling
      Error Handling
    APIs
      DataForSEO
        Labs API
        SERP API
        Backlinks API
      Slack API
    Storage
      Supabase PostgreSQL
      Google Sheets Optional
      File Storage
    Languages
      JavaScript n8n nodes
      SQL Queries
      Bash Scripts
    Testing
      Node.js
      Integration Tests
      JSON Validation
    DevOps
      GitHub Actions
      Docker Optional
      Git Version Control
```

---

## Performance Metrics

### Target Performance

| Metric | Target | Current | Status |
|--------|--------|---------|--------|
| Workflow Execution | < 45 min | 30-40 min | ✅ |
| API Calls/Run | < 500 | 400-450 | ✅ |
| Cost/Run | < $20 | $15-18 | ✅ |
| Data Freshness | Daily | Daily | ✅ |
| Error Rate | < 1% | < 0.5% | ✅ |
| Test Coverage | > 80% | 100% | ✅ |

### Monitoring Dashboards

**Recommended Metrics to Track:**
- Execution duration trend
- API cost per market
- Success/failure rate
- Data quality metrics
- Anomaly detection frequency

---

## Future Architecture Enhancements

### Phase 1: Caching Layer
```mermaid
graph LR
    N8N[n8n] --> CACHE{Cache Hit?}
    CACHE -->|Yes| DATA[Return Cached]
    CACHE -->|No| API[Call DataForSEO]
    API --> STORE[Store in Cache]
    STORE --> DATA
```

### Phase 2: ML/AI Integration
```mermaid
graph LR
    DATA[Historical Data] --> ML[ML Model]
    ML --> PRED[Opportunity Predictions]
    ML --> TREND[Trend Forecasting]
    ML --> AUTO[Auto-Optimization]
```

### Phase 3: Real-time Monitoring
```mermaid
graph LR
    WEB[Webhook Triggers] --> N8N
    N8N --> STREAM[Real-time Stream]
    STREAM --> DASH[Live Dashboard]
    STREAM --> ALERT[Instant Alerts]
```

---

**Last Updated:** November 8, 2025
**Version:** 1.0
**Maintained By:** IndieCampers SEO Team
