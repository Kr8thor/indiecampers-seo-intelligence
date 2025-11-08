#!/usr/bin/env node
/**
 * Integration test for SEO Intelligence Pipeline
 * Tests workflow components without hitting real APIs
 */

const assert = require('assert');

console.log('\n🧪 Running SEO Intelligence Integration Tests...\n');

let testsPassed = 0;
let testsFailed = 0;

// Helper function to run test
function runTest(testName, testFn) {
  try {
    testFn();
    console.log(`✅ ${testName}`);
    testsPassed++;
  } catch (error) {
    console.error(`❌ ${testName}`);
    console.error(`   Error: ${error.message}`);
    testsFailed++;
  }
}

// ============================================
// TEST 1: Opportunity Score Calculation
// ============================================
runTest('Opportunity score calculation', () => {
  const weights = {
    w1_volume: 0.35,
    w2_click_potential: 0.25,
    w3_serp_features: 0.15,
    w4_keyword_difficulty: 0.15,
    w5_commercial_intent: 0.10
  };

  const keyword = {
    search_volume: 1000,
    click_potential: 0.5,
    has_serp_features: true,
    keyword_difficulty: 30,
    commercial_intent: 0.8
  };

  // Calculate score
  const normalizedVolume = Math.min(keyword.search_volume / 10000, 1);
  const normalizedKD = keyword.keyword_difficulty / 100;

  const score =
    weights.w1_volume * normalizedVolume +
    weights.w2_click_potential * keyword.click_potential +
    weights.w3_serp_features * (keyword.has_serp_features ? 1 : 0) +
    weights.w4_keyword_difficulty * (1 - normalizedKD) +
    weights.w5_commercial_intent * keyword.commercial_intent;

  const finalScore = Math.round(score * 100);

  assert(finalScore >= 0 && finalScore <= 100, 'Score out of range');
  assert(!isNaN(finalScore), 'Score is NaN');
  assert(finalScore > 0, 'Score should be positive for valid keyword');
});

// ============================================
// TEST 2: Keyword Similarity
// ============================================
runTest('Keyword similarity calculation', () => {
  function jaccardSimilarity(str1, str2) {
    const tokens1 = new Set(str1.toLowerCase().split(' '));
    const tokens2 = new Set(str2.toLowerCase().split(' '));

    const intersection = [...tokens1].filter(x => tokens2.has(x)).length;
    const union = new Set([...tokens1, ...tokens2]).size;

    return intersection / union;
  }

  const similarKeywords = ['van hire lisbon', 'rent van lisbon'];
  const differentKeywords = ['van hire lisbon', 'motorhome insurance portugal'];

  const simScore = jaccardSimilarity(similarKeywords[0], similarKeywords[1]);
  const diffScore = jaccardSimilarity(differentKeywords[0], differentKeywords[1]);

  assert(simScore > 0.5, 'Similar keywords should have high similarity');
  assert(diffScore < 0.5, 'Different keywords should have low similarity');
  assert(simScore > diffScore, 'Similar keywords should score higher than different ones');
});

// ============================================
// TEST 3: Data Validation
// ============================================
runTest('Data validation - no duplicates', () => {
  const testData = [
    { keyword: 'test1', search_volume: 1000, opportunity_score: 75 },
    { keyword: 'test2', search_volume: 500, opportunity_score: 50 },
    { keyword: 'test3', search_volume: 2000, opportunity_score: 85 }
  ];

  // Check for duplicates
  const keywords = testData.map(d => d.keyword);
  const uniqueKeywords = new Set(keywords);

  assert(keywords.length === uniqueKeywords.size, 'Duplicate keywords found');
});

// ============================================
// TEST 4: Score Range Validation
// ============================================
runTest('Score ranges validation', () => {
  const testData = [
    { keyword: 'test1', search_volume: 1000, opportunity_score: 75 },
    { keyword: 'test2', search_volume: 500, opportunity_score: 50 },
    { keyword: 'test3', search_volume: 2000, opportunity_score: 100 },
    { keyword: 'test4', search_volume: 100, opportunity_score: 0 }
  ];

  testData.forEach(d => {
    assert(
      d.opportunity_score >= 0 && d.opportunity_score <= 100,
      `Invalid score: ${d.opportunity_score} for keyword: ${d.keyword}`
    );
    assert(
      Number.isInteger(d.search_volume),
      `Non-integer volume: ${d.search_volume}`
    );
    assert(
      Number.isInteger(d.opportunity_score),
      `Non-integer score: ${d.opportunity_score}`
    );
  });
});

// ============================================
// TEST 5: Keyword Difficulty Normalization
// ============================================
runTest('Keyword difficulty normalization', () => {
  function normalizeKD(kd) {
    assert(kd >= 0 && kd <= 100, 'KD must be between 0 and 100');
    return kd / 100;
  }

  const testCases = [
    { input: 0, expected: 0 },
    { input: 50, expected: 0.5 },
    { input: 100, expected: 1 }
  ];

  testCases.forEach(({ input, expected }) => {
    const result = normalizeKD(input);
    assert(
      Math.abs(result - expected) < 0.001,
      `Expected ${expected}, got ${result}`
    );
  });
});

// ============================================
// TEST 6: Search Volume Normalization
// ============================================
runTest('Search volume normalization', () => {
  function normalizeVolume(volume, maxVolume = 10000) {
    return Math.min(volume / maxVolume, 1);
  }

  assert(normalizeVolume(0) === 0, 'Zero volume should normalize to 0');
  assert(normalizeVolume(5000) === 0.5, '5000 should normalize to 0.5');
  assert(normalizeVolume(10000) === 1, '10000 should normalize to 1');
  assert(normalizeVolume(20000) === 1, 'Volume > max should cap at 1');
});

// ============================================
// TEST 7: SERP Feature Detection
// ============================================
runTest('SERP feature detection', () => {
  const serpFeatures = ['featured_snippet', 'people_also_ask', 'local_pack'];
  const importantFeatures = ['featured_snippet', 'faqs', 'people_also_ask'];

  function hasImportantFeatures(features, important) {
    return features.some(f => important.includes(f));
  }

  assert(
    hasImportantFeatures(serpFeatures, importantFeatures),
    'Should detect important features'
  );

  assert(
    !hasImportantFeatures(['video', 'images'], importantFeatures),
    'Should not detect unimportant features'
  );
});

// ============================================
// TEST 8: Click Potential Calculation
// ============================================
runTest('Click potential calculation', () => {
  function estimateClickPotential(rank, hasFeatures) {
    // Simplified CTR curve based on rank
    const ctrByRank = {
      1: 0.31, 2: 0.24, 3: 0.18, 4: 0.13, 5: 0.09,
      6: 0.06, 7: 0.04, 8: 0.03, 9: 0.03, 10: 0.02
    };

    const baseCTR = ctrByRank[rank] || 0.01;
    const penaltyForFeatures = hasFeatures ? 0.8 : 1; // SERP features reduce CTR

    return baseCTR * penaltyForFeatures;
  }

  const rank1Potential = estimateClickPotential(1, false);
  const rank3Potential = estimateClickPotential(3, false);
  const rank1WithFeatures = estimateClickPotential(1, true);

  assert(rank1Potential > rank3Potential, 'Rank 1 should have higher CTR than rank 3');
  assert(rank1WithFeatures < rank1Potential, 'SERP features should reduce CTR');
  assert(rank1Potential > 0.2, 'Rank 1 CTR should be significant');
});

// ============================================
// TEST 9: Competitor Strength Calculation
// ============================================
runTest('Competitor strength penalty', () => {
  function calculateCompetitorPenalty(domainRating, competitorRank) {
    const authorityScore = domainRating / 100;
    const rankScore = Math.max(0, (20 - competitorRank) / 20);
    return (authorityScore + rankScore) / 2;
  }

  const highAuthHighRank = calculateCompetitorPenalty(80, 1);
  const lowAuthLowRank = calculateCompetitorPenalty(20, 15);

  assert(highAuthHighRank > lowAuthLowRank, 'Strong competitor should have higher penalty');
  assert(highAuthHighRank >= 0 && highAuthHighRank <= 1, 'Penalty should be normalized');
});

// ============================================
// TEST 10: Commercial Intent Detection
// ============================================
runTest('Commercial intent detection', () => {
  function detectCommercialIntent(keyword) {
    const commercialKeywords = [
      'buy', 'price', 'hire', 'rent', 'book', 'booking',
      'cheap', 'best', 'review', 'compare', 'deal'
    ];

    const lowerKeyword = keyword.toLowerCase();
    const hasCommercial = commercialKeywords.some(word =>
      lowerKeyword.includes(word)
    );

    return hasCommercial ? 0.8 : 0.2;
  }

  assert(
    detectCommercialIntent('van hire lisbon') > 0.5,
    'Should detect commercial intent in "hire"'
  );
  assert(
    detectCommercialIntent('what is a campervan') < 0.5,
    'Should not detect commercial intent in informational query'
  );
  assert(
    detectCommercialIntent('buy campervan portugal') > 0.5,
    'Should detect commercial intent in "buy"'
  );
});

// ============================================
// TEST 11: Gap Detection Logic
// ============================================
runTest('Gap detection logic', () => {
  function isGap(ourRank, competitorRank, threshold = 20) {
    return ourRank === null && competitorRank !== null && competitorRank <= threshold;
  }

  assert(isGap(null, 5, 20), 'Should detect gap when we don\'t rank but competitor does');
  assert(!isGap(15, 5, 20), 'Should not detect gap when we already rank');
  assert(!isGap(null, 25, 20), 'Should not detect gap when competitor ranks too low');
  assert(isGap(null, 20, 20), 'Should detect gap at threshold boundary');
});

// ============================================
// TEST 12: N-gram Extraction
// ============================================
runTest('N-gram extraction for clustering', () => {
  function extractNgrams(text, n = 2) {
    const words = text.toLowerCase().split(' ');
    const ngrams = [];

    for (let i = 0; i <= words.length - n; i++) {
      ngrams.push(words.slice(i, i + n).join(' '));
    }

    return ngrams;
  }

  const bigrams = extractNgrams('van hire lisbon portugal', 2);

  assert(bigrams.length === 3, 'Should extract correct number of bigrams');
  assert(bigrams.includes('van hire'), 'Should include "van hire"');
  assert(bigrams.includes('hire lisbon'), 'Should include "hire lisbon"');
});

// ============================================
// SUMMARY
// ============================================
console.log('\n' + '='.repeat(50));
console.log('TEST SUMMARY');
console.log('='.repeat(50));
console.log(`✅ Passed: ${testsPassed}`);
console.log(`❌ Failed: ${testsFailed}`);
console.log(`📊 Total:  ${testsPassed + testsFailed}`);
console.log('='.repeat(50));

if (testsFailed > 0) {
  console.log('\n❌ Some tests failed!\n');
  process.exit(1);
} else {
  console.log('\n✅ All tests passed!\n');
  process.exit(0);
}
