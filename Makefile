.PHONY: up down reset logs status smoke smoke-v2 obs-up obs-down obs-status all-up all-down chaos-mongo recover-mongo adr-new adr-list

ADR_TOOLS_DIR := .tools/adr-tools

up:
	docker compose up --build -d --wait

down:
	docker compose down

reset:
	docker compose -f observability/compose.yaml down -v || true
	docker compose down -v

logs:
	docker compose logs -f --tail=150

status:
	docker compose ps

smoke:
	bash scripts/smoke.sh

smoke-v2:
	bash scripts/smoke-v2.sh

obs-up:
	docker compose -f observability/compose.yaml up -d

obs-down:
	docker compose -f observability/compose.yaml down

obs-status:
	docker compose -f observability/compose.yaml ps

all-up: up obs-up

all-down: obs-down down

chaos-mongo:
	docker compose stop mongo audit-api

recover-mongo:
	docker compose up -d --wait mongo audit-api

$(ADR_TOOLS_DIR):
	git clone --depth 1 https://github.com/npryce/adr-tools.git $(ADR_TOOLS_DIR)

# Uso: make adr-new TITLE="Usar Kafka para eventos de dominio"
adr-new: $(ADR_TOOLS_DIR)
	@test -n "$(TITLE)" || (echo "Uso: make adr-new TITLE=\"Titulo de la decision\"" && exit 1)
	PATH="$(ADR_TOOLS_DIR)/src:$$PATH" adr new $(TITLE)

adr-list: $(ADR_TOOLS_DIR)
	PATH="$(ADR_TOOLS_DIR)/src:$$PATH" adr list
