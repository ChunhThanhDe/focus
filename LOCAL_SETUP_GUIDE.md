# Focus - Local Development Setup Guide

This guide will help you set up and run the Focus Flutter application locally. The project consists of two main components:
1. **Dart Server** - Backend API server that handles Unsplash image requests
2. **Flutter Application** - The main desktop/web application

## Prerequisites

### Required Software
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (>=3.22.0)
- [Dart SDK](https://dart.dev/get-dart) (>=3.6.0)
- [FVM (Flutter Version Management)](https://fvm.app/) - Recommended for Flutter version management

### API Keys
- [Unsplash API Access Key](https://unsplash.com/oauth/applications) - Required for background image functionality

## Step 1: Environment Setup

### 1.1 Create Environment File
Create a `.env` file in the **server** directory (`server/.env`) with your Unsplash API key:

```bash
UNSPLASH_ACCESS_KEY=your_unsplash_access_key_here
```

**Note:** You can get your Unsplash API key by:
1. Creating an account at [Unsplash Developers](https://unsplash.com/developers)
2. Creating a new application
3. Copying the "Access Key" from your application dashboard

### 1.2 Install Dependencies

#### For the Server:
```bash
cd server
fvm dart pub get
```

#### For the Flutter App:
```bash
# From project root
fvm flutter pub get

# Install shared package dependencies
cd shared
fvm dart pub get
cd ..
```

#### Generate Code (if needed):
```bash
# From project root - generates MobX and JSON serialization code
fvm flutter pub run build_runner build --delete-conflicting-outputs
```

## Step 2: Start the Server

### 2.1 Navigate to Server Directory
```bash
cd server
```

### 2.2 Run the Server
```bash
fvm dart run bin/server.dart
```

**Expected Output:**
```
Server listening on port 8000
```

### 2.3 Test Server (Optional)
In a new terminal, test if the server is running:

```bash
# Test basic endpoint
curl http://localhost:8000
# Expected: Hello, World!

# Test echo endpoint
curl http://localhost:8000/echo/test
# Expected: test
```

## Step 3: Run the Flutter Application

### 3.1 Configure for Local Server
The Flutter app needs to be configured to use your local server instead of the production server.

**Option A: Using Environment Variables (Recommended)**
```bash
# From project root
fvm flutter run --dart-define="SERVER=local"
```

**Option B: For Web Development**
```bash
fvm flutter run -d chrome --dart-define="SERVER=local"
```

**Option C: For Desktop Development**
```bash
# Windows
fvm flutter run -d windows --dart-define="SERVER=local"

# macOS
fvm flutter run -d macos --dart-define="SERVER=local"

# Linux
fvm flutter run -d linux --dart-define="SERVER=local"
```

### 3.2 Debug Mode (Optional)
To run in debug mode with additional logging:
```bash
fvm flutter run --dart-define="SERVER=local" --dart-define="MODE=debug"
```

## Step 4: Verify Setup

### 4.1 Check Server Connection
1. Open the Flutter app
2. Try changing the background image (if the feature is available in the UI)
3. Check the server terminal for incoming requests
4. Check the Flutter app console for any connection errors

### 4.2 Server Endpoints
The server exposes these endpoints:
- `GET /` - Health check
- `GET /echo/<message>` - Echo test
- `POST /unsplash/randomImage` - Fetch random Unsplash images

## Troubleshooting

### Common Issues

#### 1. Server Won't Start
- **Issue:** `UNSPLASH_ACCESS_KEY is missing`
- **Solution:** Ensure you have created the `.env` file in the `server/` directory with your API key

#### 2. Flutter App Can't Connect to Server
- **Issue:** Connection refused or timeout errors
- **Solution:** 
  - Ensure the server is running on port 8000
  - Verify you're using `--dart-define="SERVER=local"`
  - Check firewall settings

#### 3. Dependencies Issues
- **Issue:** Package resolution errors
- **Solution:** 
  ```bash
  fvm flutter clean
  fvm flutter pub get
  fvm flutter pub run build_runner build --delete-conflicting-outputs
  ```

#### 4. FVM Not Found
- **Issue:** `fvm: command not found`
- **Solution:** Either install FVM or replace `fvm flutter` with `flutter` and `fvm dart` with `dart`

### Server Configuration

#### Default Configuration
- **Local Server URL:** `http://localhost:8000`
- **Production Server URL:** `https://pluto-510516922464.asia-south1.run.app`
- **Port:** 8000 (configurable via `PORT` environment variable)

#### Environment Variables
- `UNSPLASH_ACCESS_KEY` - Your Unsplash API access key (required)
- `PORT` - Server port (optional, defaults to 8000)

## Development Workflow

### Typical Development Session
1. Start the server: `cd server && fvm dart run bin/server.dart`
2. In a new terminal, start Flutter: `fvm flutter run --dart-define="SERVER=local"`
3. Make changes to your code
4. Use Flutter hot reload for UI changes
5. Restart server if you modify server code

### Code Analysis
Run code analysis to check for issues:
```bash
# Analyze Flutter code
fvm flutter analyze

# Analyze server code
cd server
fvm dart analyze
```

### Available Scripts
The project includes several helpful scripts in `scripts.yaml`:

```bash
# Install dependencies
fvm flutter pub run scripts:deps

# Format code
fvm flutter pub run scripts:format

# Clean and reinstall
fvm flutter pub run scripts:clean

# Generate code
fvm flutter pub run scripts:codegen
```

## Project Structure

```
focus/
├── lib/                    # Flutter application code
│   ├── backend/           # Backend service implementations
│   ├── home/              # Home screen and related widgets
│   ├── settings/          # Settings panels and dialogs
│   ├── ui/                # Reusable UI components
│   └── utils/             # Utility classes and helpers
├── server/                # Dart server application
│   ├── bin/server.dart    # Server entry point
│   ├── lib/               # Server libraries
│   └── .env               # Environment variables (create this)
├── shared/                # Shared code between server and client
└── web/                   # Web-specific files
```

## Next Steps

Once you have the local setup running:
1. Explore the codebase structure
2. Check out the settings panel to understand available features
3. Review the MobX stores for state management patterns
4. Look at the backend service implementation for API integration patterns

For production deployment, refer to the Docker configurations in the project root and server directory.