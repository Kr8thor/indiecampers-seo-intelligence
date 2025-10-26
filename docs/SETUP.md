# Setup Guide

## 🔑 Credentials Configuration

### 1. DataForSEO API

**Get API Credentials:**
1. Go to [dataforseo.com](https://dataforseo.com)
2. Sign up or log in
3. Navigate to API Dashboard
4. Copy your `login` and `password`

**Configure in n8n:**
1. Go to n8n → Credentials → New Credential
2. Search for "DataForSEO API"
3. Enter:
   - **Login:** `your-dataforseo-login`
   - **Password:** `your-dataforseo-password`
4. Test connection
5. Save as "DataForSEO API"

**Node Reference:**
All DataForSEO nodes will use this credential automatically.

---

### 2. Google Sheets API

**Create Service Account:**

1. Go to [Google Cloud Console](https://console.cloud.google.com)
2. Create new project or select existing
3. Enable Google Sheets API:
   - APIs & Services → Enable APIs and Services
   - Search "Google Sheets API" → Enable
4. Create Service Account:
   - APIs & Services → Credentials → Create Credentials → Service Account
   - Name: `n8n-indiecampers-seo`
   - Role: `Editor`
   - Create Key (JSON format)
   - Download `service-account-key.json`

**Share Google Sheet:**
1. Create new Google Sheet
2. Note the Sheet ID from URL:
   ```
   https://docs.google.com/spreadsheets/d/{SHEET_ID}/edit
   ```
3. Click Share → Add service account email (found in JSON file)
4. Grant "Editor" permission

**Configure in n8n:**
1. Go to n8n → Credentials → New Credential
2. Search for "Google Sheets API"
3. Choose "Service Account"
4. Upload `service-account-key.json` OR paste JSON content
5. Test connection
6. Save as "Google Sheets - IndieCampers SEO"

**Update Workflow:**
1. Open workflow
2. Edit "Global Settings" node
3. Set `SHEET_ID: "your-actual-sheet-id"`
4. Save workflow

---

### 3. Slack Webhook (Optional)

**Create Webhook:**
1. Go to [api.slack.com/apps](https://api.slack.com/apps)
2. Create New App → From Scratch
3. Name: `IndieCampers SEO Alerts`
4. Select your workspace
5. Features → Incoming Webhooks → Activate
6. Add New Webhook to Workspace
7. Select channel (e.g., `#seo-alerts`)
8. Copy Webhook URL

**Configure in n8n:**
1. Go to n8n → Credentials → New Credential
2. Search for "Slack"
3. Choose "Webhook"
4. Enter:
   - **Webhook URL:** `https://hooks.slack.com/services/...`
5. Save as "Slack - SEO Alerts"

**Test Alert:**
Manually execute workflow or use "Send Slack Alert" node test.

---

## ⚙️ Environment Variables (Optional)

For enhanced security, use n8n environment variables:

**In `.env` file:**
```bash
DATAFORSEO_LOGIN=your-login
DATAFORSEO_PASSWORD=your-password
GOOGLE_SHEETS_ID=your-sheet-id
SLACK_WEBHOOK_URL=your-webhook-url
```

**In Global Settings node:**
```javascript
const settings = {
  SHEET_ID: process.env.GOOGLE_SHEETS_ID || "YOUR_GOOGLE_SHEET_ID",
  // ... rest of settings
};
```

---

## 📋 Initial Setup Checklist

- [ ] DataForSEO API credentials configured
- [ ] Google Sheets API service account created
- [ ] Google Sheet created and shared with service account
- [ ] Sheet ID added to Global Settings
- [ ] Slack webhook configured (optional)
- [ ] Workflow imported successfully
- [ ] All nodes show green (no credential errors)
- [ ] Dry run test completed

---

## 🚦 Scheduling

**Default:** Daily at 07:00 UTC

**To Change:**
1. Edit "Schedule Trigger" node
2. Modify cron expression:
   - Every 6 hours: `0 */6 * * *`
   - Twice daily (07:00, 19:00): `0 7,19 * * *`
   - Weekly on Monday: `0 7 * * 1`

**Manual Execution:**
- Click "Execute Workflow" button in n8n editor
- Useful for testing and backfilling data

---

## 📊 Monitoring Setup

### n8n Execution Logs

1. Go to n8n → Executions
2. Filter by workflow name
3. Review execution history:
   - Success rate
   - Execution time
   - Error messages

### Google Sheets Validation

**After first run, verify:**
1. All 8 tabs created
2. Data populated in Snapshot_Target
3. Competitors discovered
4. OpportunityScore calculated correctly

### Cost Tracking

**DataForSEO Dashboard:**
- Monitor API usage: [dataforseo.com/dashboard](https://dataforseo.com/dashboard)
- Set up budget alerts

**n8n Workflow Stats:**
- Check "Run_Log" tab in Google Sheets
- Review API call counts per execution

---

## ⚠️ Security Best Practices

1. **Never commit credentials** to version control
2. **Use environment variables** for sensitive data
3. **Restrict service account** to minimum permissions
4. **Rotate API keys** periodically
5. **Enable 2FA** on all accounts
6. **Limit Sheet sharing** to necessary users only

---

**Next Steps:** [Testing Instructions](TESTING.md)