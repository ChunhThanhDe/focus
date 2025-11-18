import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

function readJSON(filePath) {
  return JSON.parse(fs.readFileSync(filePath, 'utf8'));
}

function writeJSON(filePath, data) {
  fs.writeFileSync(filePath, JSON.stringify(data, null, 2));
}

function readPubspec() {
  const pubspecPath = path.join(__dirname, '..', 'pubspec.yaml');
  const content = fs.readFileSync(pubspecPath, 'utf8');
  const nameMatch = content.match(/^name:\s*(.+)$/m);
  const descMatch = content.match(/^description:\s*(.+)$/m);
  const versionMatch = content.match(/^version:\s*([^\s]+)$/m);
  const name = nameMatch ? nameMatch[1].trim().replace(/^"|"$/g, '') : '';
  const description = descMatch ? descMatch[1].trim().replace(/^"|"$/g, '') : '';
  const fullVersion = versionMatch ? versionMatch[1].trim() : '';
  let semanticVersion = fullVersion;
  let buildNumber = '';
  if (fullVersion.includes('+')) {
    const [sem, build] = fullVersion.split('+');
    semanticVersion = sem;
    buildNumber = build;
  }
  return { name, description, version: semanticVersion, buildNumber };
}

function sync() {
  const manifestPath = path.join(__dirname, '..', 'extension', 'manifest.json');
  const manifest = readJSON(manifestPath);
  const pubspec = readPubspec();

  const appName = manifest.name || pubspec.name || 'Focus';
  const appDescription = manifest.description || pubspec.description || '';
  const extVersion = manifest.version || pubspec.version || '0.0.0';
  const buildNumber = pubspec.buildNumber || '';
  const packageName = pubspec.name || 'focus';

  manifest.name = appName;
  manifest.version = extVersion;
  manifest.description = appDescription;
  writeJSON(manifestPath, manifest);

  const versionData = {
    app_name: appName,
    version: extVersion,
    build_number: buildNumber,
    package_name: packageName,
  };

  const versionRootPath = path.join(__dirname, '..', 'extension', 'version.json');
  writeJSON(versionRootPath, versionData);

  const newtabPath = path.join(__dirname, '..', 'extension', 'newtab', 'version.json');
  writeJSON(newtabPath, versionData);

  console.log('✅ Synchronized manifest and version.json');
  console.log(`   name: ${appName}`);
  console.log(`   version: ${extVersion} (+${buildNumber || '0'})`);
  console.log(`   description: ${appDescription}`);
}

sync();