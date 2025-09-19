#!/usr/bin/env node

const fs = require('fs');
const path = require('path');

/**
 * Copy bundled social cleaner content script to extension/social_cleaner/
 */

const sourceDir = path.join(__dirname, '..', 'feed-focus', 'build');
const targetDir = path.join(__dirname, '..', 'extension', 'social_cleaner');

function main() {
  console.log('🧹 Copying social cleaner bundle to extension/social_cleaner/...');
  
  if (!fs.existsSync(sourceDir)) {
    console.error('❌ Social cleaner build not found. Run "npm run build:ts" first.');
    process.exit(1);
  }
  
  // Ensure target directory exists
  if (!fs.existsSync(targetDir)) {
    fs.mkdirSync(targetDir, { recursive: true });
  }
  
  // Copy intercept.js as content.js
  const interceptSource = path.join(sourceDir, 'intercept.js');
  const contentTarget = path.join(targetDir, 'content.js');
  
  if (fs.existsSync(interceptSource)) {
    fs.copyFileSync(interceptSource, contentTarget);
    console.log('✅ Content script copied: intercept.js → content.js');
  } else {
    console.error('❌ intercept.js not found in build directory');
    process.exit(1);
  }
  
  // Copy CSS file if it exists
  const cssSource = path.join(sourceDir, 'eradicate.css');
  const cssTarget = path.join(targetDir, 'eradicate.css');
  
  if (fs.existsSync(cssSource)) {
    fs.copyFileSync(cssSource, cssTarget);
    console.log('✅ CSS file copied: eradicate.css');
  } else {
    console.warn('⚠️  eradicate.css not found, skipping...');
  }
  
  console.log('✅ Social cleaner bundle copied successfully!');
  console.log(`   Source: ${sourceDir}`);
  console.log(`   Target: ${targetDir}`);
}

if (require.main === module) {
  main();
}

module.exports = { main };