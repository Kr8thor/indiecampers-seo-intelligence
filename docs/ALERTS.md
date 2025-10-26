# Alert Examples

## 📡 Slack Alert Payloads

### Alert Type 1: Competitor Surge Detected

**Trigger:** Competitor gains ≥10 positions or +20% visibility

**Slack Message:**
```
🚨 **SEO Alert: Competitor Surge Detected**

**Market:** Portugal (PT)
**Device:** Desktop
**Date:** 2025-10-26

🔴 **HIGH SEVERITY**

**Competitor:** campingcar.pt
**Change:** â†'️ +12 positions (from #8 to #3)
**Keyword:** "van hire lisbon"
**Search Volume:** 2,400/month
**Est. Traffic Loss:** ~840 visits/month

**Action Required:**
1. Review their updated content
2. Check for new backlinks
3. Analyze SERP features gained

[View Full Analysis](https://docs.google.com/spreadsheets/d/YOUR_SHEET_ID)
```

**JSON Payload:**
```json
{
  "text": "🚨 SEO Alert: Competitor Surge Detected",
  "blocks": [
    {
      "type": "header",
      "text": {
        "type": "plain_text",
        "text": "🚨 Competitor Surge Detected"
      }
    },
    {
      "type": "section",
      "fields": [
        {"type": "mrkdwn", "text": "*Market:*\nPortugal (PT)"},
        {"type": "mrkdwn", "text": "*Device:*\nDesktop"},
        {"type": "mrkdwn", "text": "*Competitor:*\ncampingcar.pt"},
        {"type": "mrkdwn", "text": "*Severity:*\n🔴 HIGH"}
      ]
    },
    {
      "type": "section",
      "text": {
        "type": "mrkdwn",
        "text": "*Keyword:* van hire lisbon\n*Change:* â†'️ +12 positions (#8 â→ #3)\n*Volume:* 2,400/mo\n*Est. Traffic Loss:* ~840 visits/mo"
      }
    },
    {
      "type": "actions",
      "elements": [
        {
          "type": "button",
          "text": {"type": "plain_text", "text": "View Analysis"},
          "url": "https://docs.google.com/spreadsheets/d/YOUR_SHEET_ID",
          "style": "primary"
        },
        {
          "type": "button",
          "text": {"type": "plain_text", "text": "Check SERP"},
          "url": "https://www.google.com/search?q=van+hire+lisbon"
        }
      ]
    }
  ]
}
```

---

### Alert Type 2: High-Value Gaps Discovered

**Trigger:** New keywords with OpportunityScore ≥ 75

**Slack Message:**
```
âœ¨ **SEO Opportunity: New High-Value Gaps Found**

**Market:** Spain (ES)
**Device:** Mobile
**Date:** 2025-10-26

**New Opportunities Discovered:** 12

**Top 5 Keywords:**
1️⃣ alquiler autocaravana madrid (Score: 87)
   â€¢ Volume: 3,200/mo | Difficulty: 32 | Est. Traffic: 1,120/mo
   
2️⃣ camper van rental spain (Score: 82)
   â€¢ Volume: 2,800/mo | Difficulty: 38 | Est. Traffic: 980/mo
   
3️⃣ motorhome hire barcelona (Score: 79)
   â€¢ Volume: 1,900/mo | Difficulty: 35 | Est. Traffic: 665/mo
   
4️⃣ rent campervan seville (Score: 78)
   â€¢ Volume: 1,400/mo | Difficulty: 30 | Est. Traffic: 490/mo
   
5️⃣ autocaravana alquiler valencia (Score: 76)
   â€¢ Volume: 1,200/mo | Difficulty: 33 | Est. Traffic: 420/mo

**Recommended Actions:**
• Create landing pages for top 3 keywords
• Optimize existing Madrid content
• Build local market pages for Barcelona/Seville

[View All Gaps](https://docs.google.com/spreadsheets/d/YOUR_SHEET_ID/edit#gid=GAPS_TAB)
[View Content Briefs](https://docs.google.com/spreadsheets/d/YOUR_SHEET_ID/edit#gid=BRIEFS_TAB)
```

**JSON Payload:**
```json
{
  "text": "â¨ New High-Value SEO Opportunities",
  "blocks": [
    {
      "type": "header",
      "text": {
        "type": "plain_text",
        "text": "â¨ New High-Value Gaps Found"
      }
    },
    {
      "type": "section",
      "fields": [
        {"type": "mrkdwn", "text": "*Market:*\nSpain (ES)"},
        {"type": "mrkdwn", "text": "*Device:*\nMobile"},
        {"type": "mrkdwn", "text": "*Count:*\n12 new gaps"},
        {"type": "mrkdwn", "text": "*Est. Traffic:*\n~4,675/mo"}
      ]
    },
    {
      "type": "section",
      "text": {
        "type": "mrkdwn",
        "text": "*Top Opportunities:*\n1. alquiler autocaravana madrid (Score: 87)\n2. camper van rental spain (Score: 82)\n3. motorhome hire barcelona (Score: 79)"
      }
    },
    {
      "type": "actions",
      "elements": [
        {
          "type": "button",
          "text": {"type": "plain_text", "text": "View Gaps"},
          "url": "https://docs.google.com/spreadsheets/d/YOUR_SHEET_ID/edit#gid=GAPS_TAB",
          "style": "primary"
        },
        {
          "type": "button",
          "text": {"type": "plain_text", "text": "Content Briefs"},
          "url": "https://docs.google.com/spreadsheets/d/YOUR_SHEET_ID/edit#gid=BRIEFS_TAB"
        }
      ]
    }
  ]
}
```

---

### Alert Type 3: Technical Issues Detected

**Trigger:** Critical technical problems found (optional module)

**Slack Message:**
```
â ï¸ **SEO Alert: Technical Issues Detected**

**Market:** France (FR)
**Date:** 2025-10-26

**Issues Found:** 3

🔴 **CRITICAL**
â€¢ 5 pages returning 404 (previously ranked)
  Affected keywords: 12 (combined volume: 8,400/mo)
  
🟡 **MEDIUM**
â€¢ 15 duplicate meta descriptions
  Pages: /fr/locations/* 
  
â… **LOW**
â€¢ 8 broken images on /fr/fleet/

**Immediate Actions:**
1. Fix 404 pages (redirect or restore)
2. Update duplicate meta descriptions
3. Replace/remove broken images

[View Technical Report](https://docs.google.com/spreadsheets/d/YOUR_SHEET_ID/edit#gid=TECHNICAL_TAB)
```

---

### Alert Type 4: Daily Summary

**Trigger:** End of workflow execution (optional)

**Slack Message:**
```
â… **Daily SEO Intelligence Report**

**Date:** 2025-10-26
**Run Duration:** 38 minutes
**Status:** Success

**Markets Processed:** 5 (PT, ES, FR, DE, GB)
**Devices:** Desktop + Mobile

**Key Metrics:**
â€¢ Keywords Harvested: 24,500
â€¢ Gaps Identified: 3,200
â€¢ Clusters Created: 156
â€¢ Content Briefs: 42

**Top Opportunities (All Markets):**
1. van hire portugal (PT, Score: 92)
2. alquiler autocaravana madrid (ES, Score: 87)
3. location camping-car paris (FR, Score: 85)

**Competitor Activity:**
â€¢ No significant surges detected
â€¢ 3 new competitors discovered
â€¢ Average competitor strength: Stable

**API Usage:**
â€¢ Total Calls: 485
â€¢ Cost: $15.80 USD
â€¢ Monthly Projection: $474 USD

[View Full Report](https://docs.google.com/spreadsheets/d/YOUR_SHEET_ID)
```

---

## 📧 Email Alert Alternative

If using email instead of Slack:

**Subject Line:**
```
[SEO Alert] Competitor Surge: campingcar.pt gains #3 for "van hire lisbon"
```

**HTML Template:**
```html
<!DOCTYPE html>
<html>
<head>
  <style>
    body { font-family: Arial, sans-serif; line-height: 1.6; }
    .alert-box { border: 2px solid #ff4444; padding: 20px; margin: 20px 0; }
    .metric { background: #f5f5f5; padding: 10px; margin: 5px 0; }
    .button { background: #0066cc; color: white; padding: 10px 20px; text-decoration: none; }
  </style>
</head>
<body>
  <div class="alert-box">
    <h2>🚨 Competitor Surge Detected</h2>
    
    <div class="metric">
      <strong>Market:</strong> Portugal (PT)<br>
      <strong>Device:</strong> Desktop<br>
      <strong>Date:</strong> 2025-10-26
    </div>
    
    <div class="metric">
      <strong>Competitor:</strong> campingcar.pt<br>
      <strong>Change:</strong> +12 positions (from #8 to #3)<br>
      <strong>Keyword:</strong> "van hire lisbon"<br>
      <strong>Volume:</strong> 2,400/month<br>
      <strong>Est. Traffic Loss:</strong> ~840 visits/month
    </div>
    
    <h3>Recommended Actions:</h3>
    <ol>
      <li>Review competitor's updated content</li>
      <li>Check for new backlinks</li>
      <li>Analyze SERP features gained</li>
      <li>Update our content strategy</li>
    </ol>
    
    <p>
      <a href="https://docs.google.com/spreadsheets/d/YOUR_SHEET_ID" class="button">
        View Full Analysis
      </a>
    </p>
  </div>
</body>
</html>
```

---

## 🔔 Alert Configuration

### Customize Alert Thresholds

**In Global Settings node:**
```javascript
const settings = {
  // ...
  
  ALERT_THRESHOLDS: {
    competitor_surge: {
      position_change: 10,     // +/- positions
      visibility_change: 0.20  // +/- 20%
    },
    
    high_value_gap: {
      min_opportunity_score: 75,
      min_volume: 500,
      alert_on_count: 5  // Alert if ≥5 new gaps
    },
    
    daily_summary: {
      enabled: true,
      time: "18:00"  // Send at 6 PM local
    }
  }
};
```

---

## 🔧 Slack Channel Setup

### Recommended Channels

1. **#seo-alerts** (Critical): 
   - Competitor surges
   - Technical issues
   - High-value gaps

2. **#seo-daily** (Summary):
   - Daily summary reports
   - Run completion notifications
   - Cost tracking updates

3. **#seo-dev** (Debug):
   - Workflow errors
   - API issues
   - QA failures

### Webhook Configuration

**Per Channel:**
- #seo-alerts: `https://hooks.slack.com/services/T.../B.../critical`
- #seo-daily: `https://hooks.slack.com/services/T.../B.../summary`
- #seo-dev: `https://hooks.slack.com/services/T.../B.../debug`

**In Workflow:**
- Use IF nodes to route to appropriate webhook
- Set severity-based routing

---

## 📈 Alert Analytics

### Track Alert Effectiveness

**Add to Run_Log:**
```javascript
{
  alerts_sent: 3,
  alert_types: ["competitor_surge", "high_value_gaps"],
  alert_channels: ["#seo-alerts", "#seo-alerts"],
  user_actions_taken: null  // Track manually
}
```

**Monthly Review:**
- False positive rate
- Action taken percentage
- Time to response
- Impact of alert-driven actions

---

**Back to:** [README](../README.md)