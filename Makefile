VENV := .venv
PYTHON_BOOTSTRAP ?= python3.12
PYTHON := $(VENV)/bin/python
ALEMBIC := $(VENV)/bin/alembic
UVICORN := $(VENV)/bin/uvicorn
DOCKER_COMPOSE := docker compose
LAN_HOST ?= 192.168.0.100

.PHONY: install reinstall check-python dev dev-lan infra-up db-up storage-up db-ready storage-ready db-down migrate test

install: check-python
	@if [ ! -x "$(PYTHON)" ]; then \
		if [ -d "$(VENV)" ]; then \
			echo "Existing $(VENV) is missing an executable Python. Run 'make reinstall' to recreate it."; \
			exit 1; \
		fi; \
		$(PYTHON_BOOTSTRAP) -m venv $(VENV); \
	fi
	$(PYTHON) -m pip install --upgrade pip
	$(PYTHON) -m pip install -e ".[dev]"

reinstall: check-python
	rm -rf $(VENV)
	$(PYTHON_BOOTSTRAP) -m venv $(VENV)
	$(PYTHON) -m pip install --upgrade pip
	$(PYTHON) -m pip install -e ".[dev]"

check-python:
	@command -v $(PYTHON_BOOTSTRAP) >/dev/null 2>&1 || { \
		echo "Python bootstrap command '$(PYTHON_BOOTSTRAP)' was not found."; \
		echo "Install Python 3.12+ or run: make install PYTHON_BOOTSTRAP=/path/to/python3.12"; \
		exit 1; \
	}
	@$(PYTHON_BOOTSTRAP) -c 'import sys; sys.exit("Python 3.12+ is required, got %s.%s. Set PYTHON_BOOTSTRAP=/path/to/python3.12" % sys.version_info[:2]) if sys.version_info < (3, 12) else sys.exit(0)'

dev: infra-up db-ready storage-ready migrate
	$(UVICORN) app.main:app --reload

dev-lan: infra-up db-ready storage-ready migrate
	STORAGE_ENDPOINT_URL=http://$(LAN_HOST):9000 $(UVICORN) app.main:app --reload --host 0.0.0.0 --port 8000

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
