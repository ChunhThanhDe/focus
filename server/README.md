# Dart Server with Shelf & Unsplash Integration

A lightweight server application built using [Shelf](https://pub.dev/packages/shelf), with support for serving HTTP routes and integrating with the [Unsplash API](https://unsplash.com/documentation). It also supports running in [Docker](https://www.docker.com/) environments, making it easy to deploy on cloud platforms or locally for development.

This server exposes the following routes:

- `GET /` – Simple test route
- `GET /echo/<message>` – Returns back the message sent
- `POST /unsplash/randomImage` – Returns a random image from Unsplash based on a source type (collection, tags, etc.)

---

## 📦 Prerequisites

- [Dart SDK](https://dart.dev/get-dart) (>= 3.0.0)
- A valid [Unsplash API Access Key](https://unsplash.com/oauth/applications)
- Optional: [Docker](https://www.docker.com/get-started) for containerized deployment

Set the `UNSPLASH_ACCESS_KEY` as an environment variable or in a `.env` file.

---

## 🚀 Running the Server

### 🧪 1. With Dart SDK (Local Dev)

Run the server from your terminal:

```bash
dart run bin/server.dart
````

If the environment is correctly configured, you should see:

```
Server listening on port 8000
```

### 🔄 2. Call Test Endpoints

In another terminal:

```bash
curl http://0.0.0.0:8000
# => Hello, World!

curl http://0.0.0.0:8000/echo/I_love_Dart
# => I_love_Dart
```

### 🖼 3. Fetch Unsplash Random Image

Example (using curl or Postman):

```bash
curl -X POST http://0.0.0.0:8000/unsplash/randomImage \
  -H "Content-Type: application/json" \
  -d '{"source": {"type": "random", "name": "Random"}}'
```

---

## 🐳 Running with Docker

Build and run the image:

```bash
docker build . -t dart-unsplash-server
docker run -it -p 8000:8000 dart-unsplash-server
```

Then call the same endpoints as above:

```bash
curl http://0.0.0.0:8000
curl http://0.0.0.0:8000/echo/I_love_Dart
```

### 🔍 Example Logs

You will see log outputs in the terminal:

```
2025-05-15T15:47:04.620417  GET [200] /
2025-05-15T15:47:08.392928  GET [200] /echo/I_love_Dart
```

---

## 📁 Project Structure

```
.
├── bin/
│   └── server.dart         # Entry point
├── lib/
│   └── unsplash.dart       # Logic to call Unsplash API
├── shared/                 # Shared models & utils
├── Dockerfile
├── .env                    # Optional environment file
└── README.md
```

---

## 🛠 Environment Variables

Set `UNSPLASH_ACCESS_KEY` in a `.env` file at the project root (automatically loaded):

```env
UNSPLASH_ACCESS_KEY=your_access_key_here
```
