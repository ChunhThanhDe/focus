import fs from 'fs-extra';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

async function copyFlutterWeb() {
  const sourceDir = path.join(__dirname, '..', 'build', 'web');
  const targetDir = path.join(__dirname, '..', 'extension', 'newtab');
  const extRootDir = path.join(__dirname, '..', 'extension');

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

    const newtabManifest = path.join(targetDir, 'manifest.json');
    const extManifest = path.join(extRootDir, 'manifest.json');
    if (await fs.pathExists(newtabManifest)) {
      const data = await fs.readJSON(newtabManifest);
      await fs.writeJSON(extManifest, data, { spaces: 2 });
      await fs.remove(newtabManifest);
      console.log('🔁 Moved manifest.json from newtab/ to extension/');
    }
    
  } catch (error) {
    console.error('❌ Error copying Flutter web build:', error);
    process.exit(1);
  }
}

copyFlutterWeb();