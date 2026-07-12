.PHONY: up down setup env install db-up db-wait db-migrate db-seed db-seed-force \
	api-dev client-dev docker-up docker-down docker-build logs help

SERVER := presight-assignment-server
CLIENT := presight-assignment-client
DATABASE_URL ?= postgres://presight:presight@localhost:5432/presight
export DATABASE_URL

# Local development: Postgres in Docker + API/client on the host with hot reload
up: setup
	@echo ""
	@echo "Starting API (http://localhost:3001) and client (http://localhost:5173)..."
	@echo "Press Ctrl+C to stop both."
	@echo ""
	@npx --yes concurrently -k -n api,web -c blue,magenta \
		"npm run dev --prefix $(SERVER)" \
		"npm run dev --prefix $(CLIENT)"

# Install deps, start Postgres, migrate, seed (no app servers)
setup: env install db-up db-wait db-migrate db-seed

env:
	@test -f $(SERVER)/.env || cp $(SERVER)/.env.example $(SERVER)/.env
	@test -f $(CLIENT)/.env || (test -f $(CLIENT)/.env.example && cp $(CLIENT)/.env.example $(CLIENT)/.env || true)
	@echo "Env files ready."

install:
	npm install --prefix $(SERVER)
	npm install --prefix $(CLIENT)

db-up:
	docker compose up -d postgres

db-wait:
	@echo "Waiting for Postgres..."
	@until docker compose exec -T postgres pg_isready -U presight -d presight >/dev/null 2>&1; do sleep 1; done
	@echo "Postgres is ready."

db-migrate:
	npm run db:migrate --prefix $(SERVER)

db-seed:
	npm run db:seed --prefix $(SERVER)

db-seed-force:
	npm run db:seed:force --prefix $(SERVER)

api-dev:
	npm run dev --prefix $(SERVER)

client-dev:
	npm run dev --prefix $(CLIENT)

# Full stack in Docker (API + client + Postgres) — local only, not production hardening
docker-up:
	docker compose up --build -d
	@echo ""
	@echo "App:  http://localhost:8080"
	@echo "API:  http://localhost:3001"
	@echo "DB:   localhost:5432 (presight/presight)"

docker-build:
	docker compose build

docker-down:
	docker compose down

down:
	docker compose down
	@echo "Stopped Docker services. (Host npm processes: stop with Ctrl+C in their terminal.)"

logs:
	docker compose logs -f

help:
	@echo "Local development (hot reload):"
	@echo "  make up            Start Postgres + migrate/seed + API + Vite client"
	@echo "  make setup         Install, start DB, migrate, seed (no servers)"
	@echo "  make down          Stop Docker services"
	@echo ""
	@echo "Database:"
	@echo "  make db-up         Start Postgres container"
	@echo "  make db-migrate    Run migrations"
	@echo "  make db-seed       Seed users (skips if data exists)"
	@echo "  make db-seed-force Reseed from scratch"
	@echo ""
	@echo "Full Docker stack:"
	@echo "  make docker-up     Build and run postgres + api + client"
	@echo "  make docker-down   Stop the full stack"
