import fs from 'fs-extra';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

async function copyFlutterWeb() {
  const sourceDir = path.join(__dirname, '..', 'build', 'web');
  const targetDir = path.join(__dirname, '..', 'extension', 'newtab');

  try {
    // Ensure target directory exists
    await fs.ensureDir(targetDir);
    
    // Clear target directory
    await fs.emptyDir(targetDir);
    
    // Copy all files from Flutter web build
    await fs.copy(sourceDir, targetDir);
    
    console.log('✅ Flutter web build copied to extension/newtab/');
    
    // Verify critical files exist
    const criticalFiles = ['index.html', 'main.dart.js', 'flutter.js'];
    for (const file of criticalFiles) {
      const filePath = path.join(targetDir, file);
      if (await fs.pathExists(filePath)) {
        console.log(`✅ ${file} copied successfully`);
      } else {
        console.warn(`⚠️  ${file} not found in build output`);
      }
    }
    
  } catch (error) {
    console.error('❌ Error copying Flutter web build:', error);
    process.exit(1);
  }
}

copyFlutterWeb();