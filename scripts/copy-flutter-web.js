#!/usr/bin/env node

const fs = require('fs');
const path = require('path');

/**
 * Copy Flutter web build to extension/newtab/
 */

const sourceDir = path.join(__dirname, '..', 'build', 'web');
const targetDir = path.join(__dirname, '..', 'extension', 'newtab');

function copyRecursiveSync(src, dest) {
  const exists = fs.existsSync(src);
  const stats = exists && fs.statSync(src);
  const isDirectory = exists && stats.isDirectory();
  
  if (isDirectory) {
    if (!fs.existsSync(dest)) {
      fs.mkdirSync(dest, { recursive: true });
    }
    fs.readdirSync(src).forEach(childItemName => {
      copyRecursiveSync(
        path.join(src, childItemName),
        path.join(dest, childItemName)
      );
    });
  } else {
    fs.copyFileSync(src, dest);
  }
}

function main() {
  console.log('📱 Copying Flutter web build to extension/newtab/...');
  
  if (!fs.existsSync(sourceDir)) {
    console.error('❌ Flutter web build not found. Run "fvm flutter build web --web-renderer=canvaskit --csp --no-web-resources-cdn --release" first.');
    process.exit(1);
  }
  
  // Ensure target directory exists
  if (!fs.existsSync(targetDir)) {
    fs.mkdirSync(targetDir, { recursive: true });
  }
  
  // Copy all files from build/web to extension/newtab
  copyRecursiveSync(sourceDir, targetDir);
  
  console.log('✅ Flutter web build copied successfully!');
  console.log(`   Source: ${sourceDir}`);
  console.log(`   Target: ${targetDir}`);
}

if (require.main === module) {
  main();
}

module.exports = { copyRecursiveSync, main };