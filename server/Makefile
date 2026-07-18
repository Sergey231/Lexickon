PYTHON := .venv/bin/python
ALEMBIC := .venv/bin/alembic
UVICORN := .venv/bin/uvicorn
DOCKER_COMPOSE := docker compose

.PHONY: install dev db-up db-ready db-down migrate test

install:
	python3 -m venv .venv
	$(PYTHON) -m pip install -e ".[dev]"

dev: db-up db-ready migrate
	$(UVICORN) app.main:app --reload

db-up:
	$(DOCKER_COMPOSE) up -d postgres

db-ready:
	@until $(DOCKER_COMPOSE) exec -T postgres pg_isready -U lexicon -d lexicon >/dev/null 2>&1; do \
		echo "Waiting for PostgreSQL..."; \
		sleep 1; \
	done

db-down:
	$(DOCKER_COMPOSE) down

migrate:
	$(ALEMBIC) upgrade head

test:
	$(PYTHON) -m pytest
