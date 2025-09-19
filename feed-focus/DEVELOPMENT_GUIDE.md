# News Feed Eradicator - Development Setup Guide

## 🏗️ Project Architecture

This is a **browser extension** that replaces social media news feeds with inspirational quotes. Here's how it's structured:

### Key Components:
- **Content Scripts** (`src/intercept.ts`) - Injected into web pages to detect and replace feeds
- **Background Service Worker** (`src/background/service-worker.ts`) - Handles extension lifecycle
- **Options Page** (`src/options/options.ts`) - User settings interface
- **Site Handlers** (`src/sites/`) - Platform-specific logic for Facebook, Twitter, Reddit, etc.
- **Quote System** (`src/quote.ts`) - 86 built-in inspirational quotes + custom quote support
- **Redux Store** (`src/store/`) - State management for settings and quotes

## 🌍 Environment Requirements

### Required Software:
1. **Node.js** (v16 or higher recommended)
   - Download from: https://nodejs.org/
   - Includes npm package manager
   - Verify installation: `node --version` and `npm --version`

2. **Git** (for version control)
   - Download from: https://git-scm.com/
   - Verify installation: `git --version`

3. **A Chromium-based browser** for testing:
   - Google Chrome (recommended)
   - Microsoft Edge
   - Brave Browser
   - Any Chromium-based browser

### Optional but Recommended:
4. **Make** (for build commands)
   - Windows: Install via Chocolatey `choco install make` or use WSL
   - Alternative: Use npm scripts directly

## 🔧 IDE Setup & Extensions

### Recommended IDE: **Visual Studio Code**

### Essential VS Code Extensions:

1. **TypeScript and JavaScript Language Features** (Built-in)
   - Usually enabled by default
   - Provides IntelliSense, error checking, and refactoring

2. **Prettier - Code formatter**
   - Extension ID: `esbenp.prettier-vscode`
   - Auto-formats code according to project rules
   - Configure: Set as default formatter in VS Code settings

3. **ESLint** (if you add it to the project)
   - Extension ID: `ms-vscode.vscode-eslint`
   - Provides linting and code quality checks

### Helpful VS Code Extensions:

4. **Auto Rename Tag**
   - Extension ID: `formulahendry.auto-rename-tag`
   - Useful for HTML/JSX editing

5. **Bracket Pair Colorizer** (or use built-in bracket colorization)
   - Helps with nested code structures

6. **GitLens**
   - Extension ID: `eamodio.gitlens`
   - Enhanced Git capabilities

7. **Thunder Client** (optional)
   - Extension ID: `rangav.vscode-thunder-client`
   - API testing if you add backend features

8. **Browser Extension Development Tools**
   - **Web Extension API** - Extension ID: `chrome-extension-api`
   - Provides autocomplete for browser extension APIs

### VS Code Settings for This Project:

Create `.vscode/settings.json` in your project:

```json
{
  "editor.defaultFormatter": "esbenp.prettier-vscode",
  "editor.formatOnSave": true,
  "editor.codeActionsOnSave": {
    "source.fixAll": true
  },
  "typescript.preferences.importModuleSpecifier": "relative",
  "files.associations": {
    "*.str.css": "css"
  }
}
```

## 🚀 Getting Started

### 1. Clone and Setup
```bash
# Navigate to your project directory
cd news-feed-eradicator

# Install dependencies
npm install
```

### 2. Build the Extension

#### On Windows (PowerShell):
```powershell
# Create build directory
if (!(Test-Path build)) { New-Item -ItemType Directory -Path build }

# Copy assets (required before building)
if (!(Test-Path build/icons)) { New-Item -ItemType Directory -Path build/icons }
Copy-Item src/icons/* build/icons/
Copy-Item src/manifest-chrome.json build/manifest.json
Copy-Item src/options/options.html build/options.html
Copy-Item assets/icon*.png build/

# Start development mode with file watching
npx rollup -c --watch
```

#### On Linux/Mac (with make installed):
```bash
# For development (with file watching)
make dev

# OR for production build:
make build
```

#### Alternative (works on all platforms):
```bash
# Production build using npx
npx rollup -c
```

### 3. Load Extension in Browser
1. Open Chrome and go to `chrome://extensions/`
2. Enable "Developer mode" (top right toggle)
3. Click "Load unpacked" and select the `build/` folder
4. The extension icon should appear in your toolbar

## 🛠️ Development Workflow

### Available Commands:
```bash
# Development mode with file watching
make dev

# Production build
make build

# TypeScript type checking
npm run check

# Code formatting
npm run format

# Clean build artifacts
make clean
```

### Development Process:
1. Run `make dev` to start development mode
2. Make changes to TypeScript files in `src/`
3. The build will automatically update
4. **Reload the extension** in `chrome://extensions/` (click the refresh icon)
5. Test your changes on supported sites (Facebook, Twitter, Reddit, etc.)

## 🎯 Key Areas for Customization

### 1. Adding New Quotes (`src/quote.ts`)
```typescript
// Add to the BuiltinQuotes array
{
  id: 87,
  text: 'Your custom inspirational quote here',
  source: 'Author Name'
}
```

### 2. Supporting New Websites (`src/sites/`)
- Create a new file like `src/sites/newsite.ts`
- Implement `checkSite()` and `eradicate()` functions
- Add CSS selectors to target the news feed elements
- Register in `src/sites/index.ts` and `src/intercept.ts`

### 3. Customizing Appearance (`src/eradicate.css`)
- Modify the quote display styling
- Update colors, fonts, animations

### 4. Adding Features
- **Settings**: Modify `src/options/` and `src/store/`
- **New functionality**: Extend the Redux store and components

## 📁 Important Files to Understand

- **`src/manifest-chrome.json`** - Extension permissions and configuration
- **`rollup.config.js`** - Build configuration (bundles TypeScript → JavaScript)
- **`tsconfig.json`** - TypeScript compiler settings
- **`Makefile`** - Build commands and asset copying
- **`package.json`** - Dependencies and npm scripts

## 🔧 TypeScript Tips for Beginners

Since you're new to TypeScript:

1. **Types are your friend** - They catch errors before runtime
2. **Use `npm run check`** regularly to verify your code
3. **Look at existing code patterns** - The project uses consistent typing
4. **Key concepts used here:**
   - **Interfaces** for data structures (like `Quote`, `CustomQuote`)
   - **Union types** (`Quote = CustomQuote | BuiltinQuote`)
   - **Modules** for organizing code
   - **DOM manipulation** with proper typing

### TypeScript Configuration Notes:
- **Strict null checks enabled** - Variables can't be null/undefined unless explicitly typed
- **ES6 modules** - Use `import`/`export` syntax
- **DOM types included** - Full browser API support

## 🧪 Testing Your Changes

1. **Load a supported website** (facebook.com, twitter.com, reddit.com, etc.)
2. **Check that the news feed is replaced** with a quote
3. **Open the options page** (right-click extension icon → Options)
4. **Test different settings** and custom quotes
5. **Check browser console** for any errors (F12 → Console)

### Debugging Tips:
- Use `console.log()` for debugging
- Check the browser's Developer Tools (F12)
- Look at the extension's background page console in `chrome://extensions/`
- Use VS Code's built-in debugger for TypeScript

## 📦 Building for Distribution

```bash
# Create production build
make build

# The dist/ folder will contain the packaged extension
# You can upload the .zip file to Chrome Web Store
```

## 🚨 Common Issues & Solutions

### Build Issues:
- **"make command not found" on Windows**: Windows doesn't include `make` by default. Use the PowerShell commands provided above instead, or install make via:
  - **Chocolatey**: `choco install make`
  - **WSL (Windows Subsystem for Linux)**: Install Ubuntu/Debian and use Linux commands
  - **Git Bash**: May include make, but PowerShell commands are recommended
- **TypeScript errors**: Run `npm run check` to see detailed error messages
- **Missing dependencies**: Run `npm install` again
- **Assets not copying**: Make sure to run the asset copying commands before `npx rollup -c --watch`

### Extension Issues:
- **Extension not loading**: Check that you selected the `build/` folder, not the project root
- **Changes not appearing**: Reload the extension in `chrome://extensions/`
- **Permission errors**: Check `src/manifest-chrome.json` for required permissions

### Development Issues:
- **Hot reload not working**: Restart `make dev` and reload the extension
- **CSS not updating**: Clear browser cache or hard refresh (Ctrl+Shift+R)

## 📚 Learning Resources

### TypeScript:
- [TypeScript Handbook](https://www.typescriptlang.org/docs/)
- [TypeScript in 5 minutes](https://www.typescriptlang.org/docs/handbook/typescript-in-5-minutes.html)

### Browser Extensions:
- [Chrome Extension Developer Guide](https://developer.chrome.com/docs/extensions/)
- [Web Extensions API](https://developer.mozilla.org/en-US/docs/Mozilla/Add-ons/WebExtensions)

### Tools Used:
- [Rollup.js](https://rollupjs.org/) - Module bundler
- [Redux](https://redux.js.org/) - State management
- [Snabbdom](https://github.com/snabbdom/snabbdom) - Virtual DOM library

---

🎉 **You're all set!** Start with small modifications like adding new quotes or tweaking styles, then gradually work on more complex features. The codebase is well-structured and TypeScript will help guide you as you make changes.