#!/usr/bin/env node
/**
 * Validates n8n workflow JSON files
 * Usage: node scripts/validate-workflow.js workflows/seo-intelligence-pipeline.json
 */

const fs = require('fs');
const path = require('path');

function validateWorkflow(filePath) {
  console.log(`\n🔍 Validating: ${filePath}`);

  // Check file exists
  if (!fs.existsSync(filePath)) {
    console.error(`❌ File not found: ${filePath}`);
    process.exit(1);
  }

  // Parse JSON
  let workflow;
  try {
    const content = fs.readFileSync(filePath, 'utf8');
    workflow = JSON.parse(content);
    console.log('✅ Valid JSON syntax');
  } catch (e) {
    console.error(`❌ Invalid JSON: ${e.message}`);
    process.exit(1);
  }

  // Check required fields
  const requiredFields = ['name', 'nodes', 'connections'];
  for (const field of requiredFields) {
    if (!workflow[field]) {
      console.error(`❌ Missing required field: ${field}`);
      process.exit(1);
    }
  }
  console.log('✅ Required fields present');

  // Validate nodes
  if (!Array.isArray(workflow.nodes) || workflow.nodes.length === 0) {
    console.error('❌ No nodes found in workflow');
    process.exit(1);
  }
  console.log(`✅ Found ${workflow.nodes.length} nodes`);

  // Check for credentials placeholders
  const credentialIssues = [];
  workflow.nodes.forEach(node => {
    if (node.credentials) {
      Object.entries(node.credentials).forEach(([key, cred]) => {
        if (cred.id === 'REPLACE_ME' || !cred.id) {
          credentialIssues.push(`Node "${node.name}": ${key} needs credential`);
        }
      });
    }
  });

  if (credentialIssues.length > 0) {
    console.warn('⚠️  Credential warnings:');
    credentialIssues.forEach(issue => console.warn(`   - ${issue}`));
  } else {
    console.log('✅ No obvious credential issues');
  }

  // Check for hardcoded secrets
  const workflowString = JSON.stringify(workflow);
  const secretPatterns = [
    { pattern: /sk-[a-zA-Z0-9]{32,}/, name: 'API key (sk-)' },
    { pattern: /password.*[:=]\s*["'][^"']+["']/, name: 'Hardcoded password' },
    { pattern: /eyJhbGc[a-zA-Z0-9_-]+\.[a-zA-Z0-9_-]+/, name: 'JWT token' }
  ];

  const secretsFound = [];
  secretPatterns.forEach(({ pattern, name }) => {
    if (pattern.test(workflowString)) {
      secretsFound.push(name);
    }
  });

  if (secretsFound.length > 0) {
    console.error('❌ SECURITY WARNING: Possible hardcoded secrets detected:');
    secretsFound.forEach(secret => console.error(`   - ${secret}`));
    console.error('   Please use environment variables or n8n credentials instead!');
    process.exit(1);
  } else {
    console.log('✅ No hardcoded secrets detected');
  }

  // Check for TODO comments
  const todos = workflowString.match(/TODO|FIXME|XXX/gi);
  if (todos) {
    console.warn(`⚠️  Found ${todos.length} TODO/FIXME comment(s)`);
  }

  // Validate node connections
  let connectionIssues = 0;
  if (workflow.connections) {
    Object.entries(workflow.connections).forEach(([nodeName, connections]) => {
      if (!workflow.nodes.find(n => n.name === nodeName)) {
        console.warn(`⚠️  Connection references non-existent node: ${nodeName}`);
        connectionIssues++;
      }
    });
  }

  if (connectionIssues === 0) {
    console.log('✅ All node connections valid');
  }

  console.log('\n✅ Workflow validation complete\n');
}

// Run validation
const workflowPath = process.argv[2];
if (!workflowPath) {
  console.error('Usage: node validate-workflow.js <workflow-file.json>');
  console.error('Example: node validate-workflow.js workflows/seo-intelligence-pipeline.json');
  process.exit(1);
}

validateWorkflow(workflowPath);
