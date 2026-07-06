.PHONY: up setup down dev install build env db-up db-wait db-migrate db-migrate-down db-migrate-create db-seed db-seed-force

DATABASE_URL ?= postgres://presight:presight@localhost:5432/presight
export DATABASE_URL

# Bootstrap everything and start the dev server
up: setup dev

# Install deps, start Postgres, run migrations, seed data (no dev server)
setup: env install db-up db-wait db-migrate db-seed

env:
	@test -f .env || cp .env.example .env

install:
	npm install

db-up:
	docker compose up -d --wait postgres

db-wait:
	@echo "Waiting for Postgres..."
	@until docker compose exec -T postgres pg_isready -U presight -d presight >/dev/null 2>&1; do sleep 1; done

db-migrate:
	npm run db:migrate

db-migrate-down:
	npm run db:migrate:down

db-migrate-create:
	@read -p "Migration name: " name; npm run db:migrate:create -- $$name

db-seed:
	npm run db:seed

db-seed-force:
	npm run db:seed:force

dev:
	npm run dev

build:
	npm run build

down:
	docker compose down
