# Testing Instructions

## 🧪 Test Strategy

**Goal:** Validate workflow functionality before production deployment

**Approach:**
1. Unit testing (individual phases)
2. Integration testing (full workflow)
3. Data validation
4. Performance testing

---

## 🐣 Dry Run (Recommended First Test)

### Setup

**Modify Global Settings:**
```javascript
const settings = {
  TARGET_DOMAIN: "indiecampers.com",
  
  // TEST: Use only 1 market
  MARKETS: [
    {"country":"PT","language":"pt-PT","location":"Lisbon","location_code":2620}
  ],
  
  // TEST: Desktop only
  DEVICE_TYPES: ["desktop"],
  
  // TEST: Limit competitors
  MAX_COMPETITORS_PER_MARKET: 5,
  
  // TEST: Reduce keywords
  TOP_KEYWORDS_PER_DOMAIN: 200,
  
  // ... rest unchanged
};
```

### Execute

1. Open workflow in n8n editor
2. Click **"Execute Workflow"** button
3. **Expected Duration:** 3-5 minutes
4. **Expected API Calls:** ~30-40
5. **Expected Cost:** ~$1.50

### Validation Checklist

- [ ] Workflow completes without errors
- [ ] All 8 Google Sheets tabs created
- [ ] Snapshot_Target has ~200 rows
- [ ] Competitors_Selected has ~5 rows
- [ ] Competitor_Keywords_Raw has ~800-1000 rows
- [ ] Keyword_Gaps_Scored has gaps identified
- [ ] OpportunityScore calculated (values 0-100)
- [ ] Clusters tab has groups
- [ ] Content_Briefs has at least 1 brief
- [ ] Run_Log updated with execution stats

---

## 📄 Unit Testing (By Phase)

### Phase 1: Target Snapshot

**Test Node:** "📊 Get Target Keywords"

**Steps:**
1. Disable all nodes after this one
2. Execute workflow
3. Inspect output

**Expected Output:**
```json
{
  "tasks": [
    {
      "result": [
        {
          "items": [
            {
              "keyword": "van hire lisbon",
              "rank_absolute": 3,
              "search_volume": 2400,
              "keyword_difficulty": 38
              // ...
            }
          ]
        }
      ]
    }
  ]
}
```

**Validation:**
- [ ] `tasks[0].result[0].items` is array
- [ ] At least 50 keywords returned
- [ ] All keywords have `rank_absolute ≤ 100`
- [ ] `search_volume > 0` for all

---

### Phase 2: Competitor Discovery

**Test Nodes:**
- "🔍 Find Overlapping Domains"
- "🔍 Get SERP Competitors"

**Steps:**
1. Enable up to "Merge & Deduplicate Competitors" node
2. Execute
3. Check merged output

**Expected Output:**
```json
[
  {
    "competitor_domain": "campingcar.pt",
    "overlap_score": 0.68,
    "discovery_method": "labs_competitors"
  },
  {
    "competitor_domain": "yescapa.pt",
    "overlap_score": 0.54,
    "discovery_method": "serp_overlap"
  }
]
```

**Validation:**
- [ ] At least 5 unique competitors
- [ ] No duplicates in merged list
- [ ] `overlap_score` between 0 and 1
- [ ] Domains are valid (not our domain)

---

### Phase 3: Keyword Harvest

**Test Node:** Loop through competitors

**Steps:**
1. Enable "Loop Over Competitors" section
2. Limit to 2 competitors (faster test)
3. Execute

**Expected Behavior:**
- Rate limit handler activates if needed
- Backlinks fetched for each competitor
- Keywords filtered by thresholds
- No duplicate keyword+competitor pairs

**Validation:**
- [ ] ~200-400 keywords per competitor
- [ ] `competitor_rank ≤ RANK_THRESHOLD`
- [ ] All have `domain_rating` from backlinks
- [ ] Backoff triggered (check logs)

---

### Phase 4: Gap Analysis

**Test Node:** "📊 Calculate Gaps & Scores"

**Steps:**
1. Run full workflow
2. Inspect Keyword_Gaps_Scored output

**Expected Logic:**
```javascript
// Gap exists when:
our_rank === null && competitor_rank ≤ RANK_THRESHOLD

// Opportunity score formula:
OpportunityScore = 
  w1 * normalizedVolume +
  w2 * clickPotential +
  w3 * serpFeatureBoost +
  w4 * (1 - normalizedKD) +
  w5 * commercialIntent -
  w6 * competitorStrength
```

**Validation:**
- [ ] All gaps have `our_rank = null`
- [ ] OpportunityScore range: 0-100
- [ ] High scores (>75) are genuinely valuable
- [ ] Commercial keywords score higher
- [ ] No `NaN` or `Infinity` values

---

### Phase 5: Clustering

**Test Node:** "🧩 Cluster Keywords"

**Algorithm Test:**
```javascript
// Test cases:
[
  "van hire lisbon",
  "rent van lisbon",
  "campervan rental lisbon"
] // Should cluster together

[
  "van hire lisbon",
  "motorhome insurance portugal"
] // Should NOT cluster
```

**Validation:**
- [ ] Similar keywords grouped
- [ ] Cluster sizes reasonable (3-20 members)
- [ ] Each cluster has clear head term
- [ ] Intent classification makes sense
- [ ] SERP overlap calculated correctly

---

### Phase 6: Content Briefs

**Test Node:** "📝 Generate Brief Templates"

**Sample Output Check:**
```markdown
# Van Hire in Portugal: Complete 2025 Guide

## Introduction
[Brief intro]

## Why Rent a Van in Portugal?
- Point 1
- Point 2

## Top Van Hire Routes
...

## FAQ
**Q: How much does van hire cost in Portugal?**
A: Prices start from €45/day...
```

**Validation:**
- [ ] H1 contains target keyword
- [ ] Meta title ≤ 60 characters
- [ ] Meta description ≤ 155 characters
- [ ] At least 5 H2 sections
- [ ] 5-8 FAQ questions
- [ ] Internal link suggestions present
- [ ] Structured data hints logical

---

## 🔗 Integration Testing

### Full Workflow Test

**Configuration:**
```javascript
MARKETS: [{"country":"PT", ...}, {"country":"ES", ...}],
DEVICE_TYPES: ["desktop", "mobile"],
MAX_COMPETITORS_PER_MARKET: 10,
TOP_KEYWORDS_PER_DOMAIN: 500
```

**Execute & Monitor:**
- Duration: ~15-20 minutes
- API Calls: ~150-200
- Cost: ~$6-8

**Validation:**
- [ ] Both markets processed
- [ ] Both devices analyzed
- [ ] No data mixing between markets
- [ ] Google Sheets properly partitioned
- [ ] Run_Log shows correct counts

---

## 🔍 Data Validation

### Automated QA Checks

**Add to "QA & Validation" node:**

```javascript
const gaps = $input.all();

// Check 1: No duplicates
const uniqueKeys = new Set();
gaps.forEach(g => {
  const key = `${g.market}_${g.keyword}`;
  if (uniqueKeys.has(key)) {
    throw new Error(`Duplicate found: ${key}`);
  }
  uniqueKeys.add(key);
});

// Check 2: Valid OpportunityScores
const invalidScores = gaps.filter(
  g => isNaN(g.ic_opportunity_score) || 
       g.ic_opportunity_score < 0 || 
       g.ic_opportunity_score > 100
);
if (invalidScores.length > 0) {
  throw new Error(`${invalidScores.length} invalid scores`);
}

// Check 3: All volumes are integers
const invalidVolumes = gaps.filter(
  g => !Number.isInteger(g.search_volume)
);
if (invalidVolumes.length > 0) {
  throw new Error(`${invalidVolumes.length} non-integer volumes`);
}

console.log("✅ All QA checks passed");
return [{ json: { qa_passed: true } }];
```

---

## ⚡ Performance Testing

### Baseline Metrics

**Single Market (PT, desktop):**
- Duration: 3-5 minutes
- API Calls: 30-40
- Keywords: 800-1200
- Gaps: 200-400
- Cost: ~$1.50

**All Markets (5 × 2 devices):**
- Duration: 30-45 minutes
- API Calls: 400-500
- Keywords: 20,000-30,000
- Gaps: 3,000-5,000
- Cost: ~$15-20

### Optimization Tests

**Test 1: Reduce MAX_COMPETITORS**
- From 20 → 10
- Expected: 50% fewer API calls
- Expected: Maintain top opportunities

**Test 2: Increase Batch Size**
- Loop Over Markets: batchSize 1 → 2
- Expected: 2× throughput (if rate limits allow)
- Monitor: DataForSEO 429 errors

**Test 3: Parallel Competitor Harvesting**
- Sequential → Parallel (with rate limit)
- Expected: 30% faster execution
- Risk: Rate limit issues

---

## 🚨 Error Testing

### Simulate Common Errors

**Test 1: Invalid Credentials**
- Remove DataForSEO credentials
- Expected: Clear error message
- Expected: Workflow stops gracefully

**Test 2: Sheet Permission Error**
- Revoke service account access
- Expected: Permission denied error
- Expected: Suggested fix in error

**Test 3: Rate Limit Hit**
- Set aggressive batch size
- Expected: Exponential backoff triggers
- Expected: Retry after delay
- Expected: Eventually succeeds

**Test 4: Empty Results**
- Use domain with no rankings
- Expected: Workflow completes
- Expected: Empty tabs (no crashes)
- Expected: Log shows 0 keywords

---

## ✅ Production Readiness Checklist

### Before Activation

- [ ] **Dry run successful** (1 market, desktop)
- [ ] **Integration test passed** (2 markets, both devices)
- [ ] **Data validation clean** (no QA errors)
- [ ] **Google Sheets verified** (all tabs, correct data)
- [ ] **Cost projection acceptable** (~$15-20/run)
- [ ] **Slack alerts working** (test anomaly trigger)
- [ ] **Credentials secure** (environment variables used)
- [ ] **Schedule configured** (daily 07:00 UTC)
- [ ] **Backup strategy** (Google Sheets + version history)
- [ ] **Monitoring setup** (n8n execution logs)

### First Week Monitoring

- [ ] **Day 1:** Verify first automatic run
- [ ] **Day 2:** Check for duplicates/anomalies
- [ ] **Day 3:** Validate opportunity scores
- [ ] **Day 7:** Review Run_Log for patterns
- [ ] **Week 1 End:** Cost analysis (actual vs projected)

---

## 🐞 Troubleshooting Tests

### If Workflow Fails

1. **Check execution logs** in n8n
2. **Identify failing node**
3. **Run unit test** for that phase
4. **Verify credentials** for that service
5. **Check service status** (DataForSEO, Google)

### Common Fixes

**"Sheet not found":**
```javascript
// Add to beginning of Google Sheets nodes:
try {
  // sheet operation
} catch (e) {
  if (e.message.includes("not found")) {
    console.log("Creating tab...");
    // create tab logic
  }
}
```

**"Rate limit exceeded":**
```javascript
// Increase backoff multiplier:
RATG_LIMIT: {
  backoff_multiplier: 3, // was 2
  max_retries: 5 // was 3
}
```

---

**Next:** [Alert Examples](ALERTS.md)