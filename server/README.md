# Lexicon API Server

FastAPI backend skeleton for the Lexicon mobile app.

## Local Setup

```bash
cd server
make install
make dev
```

`make dev` starts PostgreSQL, waits until it is ready, applies Alembic migrations, and
starts the FastAPI server.

Health check:

```bash
curl http://localhost:8000/health
```

Expected response:

```json
{"status":"ok"}
```

## Environment

Settings are read from environment variables and optional `.env` files.

```text
APP_ENV=local
APP_DEBUG=true
APP_SECRET_KEY=local-dev-secret-key-change-before-production
JWT_ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=30
DATABASE_URL=postgresql+psycopg://lexicon:lexicon@localhost:5432/lexicon
```

`APP_SECRET_KEY` must be replaced with a long random value outside local development.

## Auth Smoke Test

Register and log in:

```bash
curl -X POST http://localhost:8000/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"dev@example.com","password":"password123"}'

curl -X POST http://localhost:8000/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"dev@example.com","password":"password123"}'
```

Pass the returned token to the protected endpoint:

```bash
curl http://localhost:8000/me \
  -H "Authorization: Bearer <access_token>"
```
