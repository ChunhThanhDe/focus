const fs = require('fs-extra');
const path = require('path');

async function copySocialBundle() {
  const sourceFile = path.join(__dirname, '..', 'feed-focus', 'build', 'intercept.js');
  const targetFile = path.join(__dirname, '..', 'extension', 'social_cleaner', 'content.js');

  try {
    // Ensure target directory exists
    await fs.ensureDir(path.dirname(targetFile));
    
    // Check if source file exists
    if (!(await fs.pathExists(sourceFile))) {
      console.error('❌ Source bundle not found. Run "npm run build:ts" first.');
      process.exit(1);
    }
    
    // Copy the bundled file
    await fs.copy(sourceFile, targetFile);
    
    console.log('✅ Social cleaner bundle copied to extension/social_cleaner/content.js');
    
    // Verify file size
    const stats = await fs.stat(targetFile);
    console.log(`📦 Bundle size: ${(stats.size / 1024).toFixed(2)} KB`);
    
  } catch (error) {
    console.error('❌ Error copying social bundle:', error);
    process.exit(1);
  }
}

copySocialBundle();
