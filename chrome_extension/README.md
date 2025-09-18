# News Feed Focus - Chrome Extension

A Chrome extension that removes distracting news feeds from social media platforms and replaces them with inspirational quotes to help maintain focus and productivity.

## Features

- **Multi-Platform Support**: Works on Facebook, Twitter/X, Instagram, LinkedIn, Reddit, YouTube, GitHub, and Hacker News
- **Quote System**: Displays inspirational quotes instead of distracting feeds
- **Customizable**: Configure which sites to enable/disable
- **Flutter Integration**: Settings UI built with Flutter Web
- **TypeScript**: Fully typed codebase for reliability

## Project Structure

```
chrome_extension/
├── src/
│   ├── background/
│   │   └── service-worker.ts     # Background service worker
│   ├── content/
│   │   ├── base-content-script.ts # Base class for content scripts
│   │   └── sites/                # Site-specific content scripts
│   │       ├── facebook.ts
│   │       ├── twitter.ts
│   │       ├── instagram.ts
│   │       ├── linkedin.ts
│   │       ├── reddit.ts
│   │       ├── youtube.ts
│   │       ├── github.ts
│   │       └── hackernews.ts
│   ├── data/
│   │   ├── quotes.ts            # Built-in quotes database
│   │   └── sites.ts             # Site configurations
│   ├── types/
│   │   └── index.ts             # TypeScript type definitions
│   ├── utils/
│   │   └── helpers.ts           # Utility functions
│   └── manifest.json            # Extension manifest
├── dist/                        # Built extension files
├── package.json
├── tsconfig.json
├── rollup.config.js
└── .eslintrc.js
```

## Development Setup

### Prerequisites

- Node.js 18+
- pnpm (recommended) or npm

### Installation

1. Navigate to the chrome_extension directory:
   ```bash
   cd chrome_extension
   ```

2. Install dependencies:
   ```bash
   pnpm install
   ```

### Development Commands

```bash
# Type checking
pnpm typecheck

# Linting
pnpm lint

# Fix linting issues
pnpm lint:fix

# Build for development
pnpm build

# Build for production
pnpm build:prod

# Watch mode (rebuilds on changes)
pnpm dev
```

## Loading the Extension

1. Build the extension:
   ```bash
   pnpm build
   ```

2. Open Chrome and navigate to `chrome://extensions/`

3. Enable "Developer mode" (toggle in top right)

4. Click "Load unpacked" and select the `dist` folder

5. The extension should now be loaded and active

## Usage

1. **Automatic Activation**: The extension automatically activates on supported social media sites

2. **Quote Display**: Instead of news feeds, you'll see inspirational quotes

3. **Settings**: Click the extension icon to access settings (opens Flutter UI)

4. **Customization**: Enable/disable specific sites and manage custom quotes

## Supported Sites

- **Facebook** (`facebook.com`)
- **Twitter/X** (`twitter.com`, `x.com`)
- **Instagram** (`instagram.com`)
- **LinkedIn** (`linkedin.com`)
- **Reddit** (`reddit.com`)
- **YouTube** (`youtube.com`)
- **GitHub** (`github.com`)
- **Hacker News** (`news.ycombinator.com`)

## Architecture

### Background Service Worker
- Manages extension state and storage
- Handles message passing between content scripts and UI
- Provides quote management functionality

### Content Scripts
- Site-specific scripts that modify page content
- Remove distracting elements (feeds, ads, notifications)
- Inject inspirational quotes
- Handle dynamic content updates

### Flutter Integration
- Settings UI built with Flutter Web
- Embedded in extension popup/options pages
- Communicates with background script via message passing

## Configuration

The extension stores configuration in Chrome's sync storage:

```typescript
interface StorageData {
  enabled: boolean;
  sites: Record<SiteId, SiteConfig>;
  quotes: {
    builtin: boolean;
    custom: boolean;
    customQuotes: CustomQuote[];
  };
}
```

## Contributing

1. Follow TypeScript best practices
2. Maintain consistent code style (ESLint configuration provided)
3. Test on all supported platforms
4. Update documentation for new features

## Security

- Follows Chrome Extension Manifest V3 requirements
- Minimal permissions requested
- No external network requests from content scripts
- Secure message passing between components

## License

Part of the News Feed Focus Flutter application.