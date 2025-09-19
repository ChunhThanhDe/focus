const fs = require('fs');
const path = require('path');

// Ensure build directory exists
if (!fs.existsSync('build')) {
  fs.mkdirSync('build');
}

// Copy manifest (use Chrome manifest for Chrome extension)
fs.copyFileSync('src/manifest-chrome.json', 'build/manifest.json');

// Copy HTML files
fs.copyFileSync('src/options/options.html', 'build/options.html');
fs.copyFileSync('src/background/background.html', 'build/background.html');

// Copy icons (from assets folder to build)
const iconFiles = ['icon16.png', 'icon32.png', 'icon48.png', 'icon64.png', 'icon128.png'];
iconFiles.forEach(icon => {
  const sourcePath = `assets/${icon}`;
  const destPath = `build/${icon}`;
  
  if (fs.existsSync(sourcePath)) {
    fs.copyFileSync(sourcePath, destPath);
    console.log(`Copied ${icon}`);
  } else {
    console.warn(`Warning: ${sourcePath} not found`);
  }
});

// Copy SVG icons
const svgIconFiles = ['checked.svg', 'unchecked.svg'];
svgIconFiles.forEach(icon => {
  const sourcePath = `src/icons/${icon}`;
  const destPath = `build/icons/${icon}`;
  
  // Create icons directory in build if it doesn't exist
  if (!fs.existsSync('build/icons')) {
    fs.mkdirSync('build/icons');
  }
  
  if (fs.existsSync(sourcePath)) {
    fs.copyFileSync(sourcePath, destPath);
    console.log(`Copied ${icon}`);
  } else {
    console.warn(`Warning: ${sourcePath} not found`);
  }
});

console.log('Assets copied successfully!');