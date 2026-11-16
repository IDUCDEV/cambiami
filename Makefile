# Cambiami · atajos de desarrollo.
# Ningún objetivo contiene claves: las lee del entorno o de `.env`.

SHELL := /bin/bash

SUPABASE_URL ?= http://127.0.0.1:54321
FUNCTION_URL = $(SUPABASE_URL)/functions/v1/collect-rates

.PHONY: help db-reset test-db fn-serve collect deploy

help:
	@grep -E '^[a-zA-Z_-]+:.*?## ' $(MAKEFILE_LIST) \
		| awk 'BEGIN {FS = ":.*?## "}; {printf "  %-12s %s\n", $$1, $$2}'

db-reset: ## Recrea la base local, aplica migraciones y seed
	supabase db reset

test-db: ## Corre los tests pgTAP
	supabase test db

fn-serve: ## Sirve la Edge Function con el secreto local
	@test -f supabase/functions/.env \
		|| { echo "Falta supabase/functions/.env (copiar de .env.example)"; exit 1; }
	supabase functions serve --env-file supabase/functions/.env

collect: ## Invoca el colector; requiere COLLECTOR_SECRET en el entorno
	@test -n "$(COLLECTOR_SECRET)" \
		|| { echo "Falta COLLECTOR_SECRET"; exit 1; }
	curl -sS -X POST "$(FUNCTION_URL)" \
		-H "Content-Type: application/json" \
		-H "x-collector-secret: $(COLLECTOR_SECRET)"
	@echo

deploy: ## Aplica esquema y despliega la función; requiere SUPABASE_PROJECT_REF
	@test -n "$(SUPABASE_PROJECT_REF)" \
		|| { echo "Falta SUPABASE_PROJECT_REF"; exit 1; }
	supabase db push --project-ref "$(SUPABASE_PROJECT_REF)"
	supabase functions deploy collect-rates --project-ref "$(SUPABASE_PROJECT_REF)"
	@echo "Falta programar el colector: ver docs/SUPABASE_REMOTO.md §6"
