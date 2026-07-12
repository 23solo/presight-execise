# Setup & local development

How to run this User Directory implementation.

> **Database:** **PostgreSQL** is used instead of SQLite (same schema ideas, Docker-friendly).  
> The original assignment brief is below.

## Quick start

Requires **Docker**, **Node 22+**, and **Make**.

```bash
make up
```

That command will:

1. Copy env files if missing  
2. Install client + server dependencies  
3. Start Postgres in Docker  
4. Run migrations and seed (~5,000 users)  
5. Start the API (`http://localhost:3001`) and Vite client (`http://localhost:5173`) with hot reload  

Stop the app servers with **Ctrl+C**. Stop Postgres with:

```bash
make down
```

### Make targets

| Command | What it does |
|---------|----------------|
| `make up` | Full local dev stack (DB + API + client) |
| `make setup` | Install, DB, migrate, seed — no servers |
| `make db-migrate` | Run DB migrations |
| `make db-seed` | Seed users (skips if data already exists) |
| `make db-seed-force` | Truncate and reseed |
| `make docker-up` | Run **everything** in Docker Compose |
| `make docker-down` | Stop the full Docker stack |
| `make help` | List targets |

## Docker Compose (full stack)

Runs Postgres, API, and the built client (nginx) locally.

### With Make

```bash
make docker-up
```

```bash
make docker-down
```

### Manual Docker commands

Same stack as `make docker-up`, without Make. Run from the repo root (`presight-execise/`):

```bash
# Build images
docker compose build

# Start Postgres, API, and client in the background
docker compose up -d

# Or build and start in one step
docker compose up --build -d

# Follow logs (optional)
docker compose logs -f

# Stop and remove containers (keeps the Postgres volume)
docker compose down
```

After it’s up:

| Service | URL |
|---------|-----|
| Client | http://localhost:8080 |
| API | http://localhost:3001 |
| Postgres | `localhost:5432` (user/pass/db: `presight`) |

The client nginx proxies `/api` to the API container. On first start the API entrypoint migrates and seeds automatically.

Postgres data is stored in the Docker volume `postgres_data`, so `docker compose down` keeps your DB. To wipe data as well:

```bash
docker compose down -v
```

## Manual setup (without Make)

```bash
# 1. Env
cp presight-assignment-server/.env.example presight-assignment-server/.env

# 2. Database
docker compose up -d postgres

# 3. Server
cd presight-assignment-server
npm install
npm run db:migrate
npm run db:seed
npm run dev

# 4. Client (another terminal)
cd presight-assignment-client
npm install
npm run dev
```

Vite proxies `/api` to `http://localhost:3001` when `VITE_API_BASE_URL` is empty.

## Database seeding

Seed script: `presight-assignment-server/src/db/seed.ts`

```bash
make db-seed              # no-op if users already exist
make db-seed-force        # wipe + reseed
# or:
cd presight-assignment-server && npm run db:seed
SEED_FORCE=true npm run db:seed
```

Defaults (overridable in `.env`):

- `SEED_USER_COUNT=5000`
- `SEED_FORCE=false`

Schema lives in `presight-assignment-server/migrations/` (`users`, `hobbies`, `user_hobbies`).

## API overview

| Method | Path | Purpose |
|--------|------|---------|
| `GET` | `/api/users` | Paginated, filtered, sorted users |
| `GET` | `/api/facets` | Top 20 hobbies & nationalities for current filters |
| `GET` | `/api/insights` | Extra directory insights |
| `GET` | `/healthz` | Health check |

---

# Presight Frontend Exercise

Build a small full-stack user directory application. The goal is to evaluate how you design a searchable, filterable, paginated UI backed by persisted data and clear API boundaries.

The application should include:

- A React client.
- A Node.js API server.
- A SQLite database used as the source of truth for user data.
- Docker configuration for running the application locally.

## Scenario

Users need to browse a large directory of people, search by name, and narrow results by nationality and hobbies. The filter sidebar should help users discover useful filters based on the result set they are currently viewing.

## Requirements

### Data Model

Seed a SQLite database with enough records to make pagination, infinite scroll, search, and filter counts meaningful.

Each user should have:

- `avatar`
- `first_name`
- `last_name`
- `age`
- `nationality`
- `hobbies`, from 0 to 10 hobbies per user

Choose a data model that supports the required behavior.

SQLite must be the persisted source of user data.

### API

Expose an API that supports:

- Paginated user results.
- Text filtering from user input across `first_name` and `last_name`.
- Filtering by one or more nationalities.
- Filtering by one or more hobbies.
- Sorting by `first_name`, `last_name`, `age`, and `nationality`.
- Pagination metadata so the client can determine whether more results are available.
- Top 20 hobbies for the active text filter and filter state, including `{ value, count }`.
- Top 20 nationalities for the active text filter and filter state, including `{ value, count }`.

The top 20 values and counts must reflect the currently applied text filter and selected filters, not the global dataset.

Filter semantics:

- Multiple selected hobbies should match users who have all selected hobbies.
- Multiple selected nationalities should match users from any selected nationality.
- Text, hobby, and nationality filters should apply together.

Sorting semantics:

- Sorted results must be deterministic. Use `id` as a final tie-breaker when values are equal.
- Pagination must respect the active sort without duplicate or missing users.

### Client

Build a React interface that includes:

- A text filter input for `first_name` and `last_name`.
- A virtualized, infinitely scrolling list of user cards.
- A sidebar containing the top 20 hobbies and top 20 nationalities for the current result set, including counts.
- Controls for applying and removing hobby and nationality filters.
- Controls for choosing sort field and sort direction.
- Loading, empty, and error states.
- A responsive layout that remains usable on desktop and mobile.

User cards should follow this structure:

```text
|----------------------------------|
| avatar      first_name+last_name |
|             nationality      age |
|                                  |
|             (2 hobbies) (+n)     |
|----------------------------------|
```

Show up to 2 hobbies on the card. If the user has more hobbies, display the remaining count as `+n`.

Use a virtual scroll implementation for the list.

When the text filter or selected filters change, the client must refresh both:

- The paginated user list.
- The top 20 hobbies and nationalities in the sidebar.

The text filter value, selected hobbies, selected nationalities, sort field, and sort direction must be reflected in the URL query string. Reloading or sharing the URL should restore the same view state.

## Implementation Notes

- Keep the database setup easy to run locally.
- Include seed logic or a documented command that creates the SQLite database.
- Include a `Dockerfile` and `docker-compose.yml` that can run the application locally.

## Evaluation Focus

We will pay particular attention to:

- Correct data persistence and API behavior.
- Correct filtering, sorting, pagination, and top 20 counts.
- Smooth infinite scrolling with virtualization.
- URL-synced state.
- Clear loading, empty, and error states.
- Easy local and Docker-based setup.

## Deliverables

Please provide:

- Source code for the React client and Node.js server.
- A `Dockerfile` and `docker-compose.yml`.
- Instructions for setup, database seeding, and running locally.
- Instructions for running with Docker Compose.
