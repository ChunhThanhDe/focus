#!/usr/bin/env node

const fs = require('fs');
const path = require('path');

/**
 * Copy extension icons to extension/icons/
 */

const sourceDir = path.join(__dirname, '..', 'feed-focus', 'assets');
const targetDir = path.join(__dirname, '..', 'extension', 'icons');

function main() {
  console.log('🎨 Copying extension icons to extension/icons/...');
  
  if (!fs.existsSync(sourceDir)) {
    console.error('❌ Icons source directory not found:', sourceDir);
    process.exit(1);
  }
  
  // Ensure target directory exists
  if (!fs.existsSync(targetDir)) {
    fs.mkdirSync(targetDir, { recursive: true });
  }
  
  // Icon mapping: source filename → target filename
  const iconMappings = {
    'icon16.png': '16.png',
    'icon48.png': '48.png',
    'icon128.png': '128.png'
  };
  
  let copiedCount = 0;
  
  for (const [sourceFile, targetFile] of Object.entries(iconMappings)) {
    const sourcePath = path.join(sourceDir, sourceFile);
    const targetPath = path.join(targetDir, targetFile);
    
    if (fs.existsSync(sourcePath)) {
      fs.copyFileSync(sourcePath, targetPath);
      console.log(`✅ Icon copied: ${sourceFile} → ${targetFile}`);
      copiedCount++;
    } else {
      console.warn(`⚠️  Icon not found: ${sourceFile}`);
    }
  }
  
  if (copiedCount === 0) {
    console.error('❌ No icons were copied. Check source directory.');
    process.exit(1);
  }
  
  console.log(`✅ ${copiedCount} icons copied successfully!`);
  console.log(`   Source: ${sourceDir}`);
  console.log(`   Target: ${targetDir}`);
}

if (require.main === module) {
  main();
}

module.exports = { main };