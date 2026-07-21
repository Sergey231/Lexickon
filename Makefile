PYTHON := .venv/bin/python
ALEMBIC := .venv/bin/alembic
UVICORN := .venv/bin/uvicorn
DOCKER_COMPOSE := docker compose

.PHONY: install dev infra-up db-up storage-up db-ready storage-ready db-down migrate test

install:
	python3 -m venv .venv
	$(PYTHON) -m pip install -e ".[dev]"

dev: infra-up db-ready storage-ready migrate
	$(UVICORN) app.main:app --reload

infra-up: db-up storage-up

db-up:
	$(DOCKER_COMPOSE) up -d postgres

storage-up:
	$(DOCKER_COMPOSE) up -d minio

db-ready:
	@until $(DOCKER_COMPOSE) exec -T postgres pg_isready -U lexicon -d lexicon >/dev/null 2>&1; do \
		echo "Waiting for PostgreSQL..."; \
		sleep 1; \
	done

storage-ready:
	@until $(DOCKER_COMPOSE) run --rm minio-create-bucket >/dev/null 2>&1; do \
		echo "Waiting for MinIO..."; \
		sleep 1; \
	done

db-down:
	$(DOCKER_COMPOSE) down

migrate:
	$(ALEMBIC) upgrade head

test:
	$(PYTHON) -m pytest
