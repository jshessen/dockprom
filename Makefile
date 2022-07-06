.DEFAULT_GOAL:=help
# --------------------------
-include .env
export
# --------------------------
COMPOSE_MONITORING := -f docker-compose.yml
MONITORING_SERVICES := caddy prometheus alertmanager grafana

COMPOSE_EXPORTERS := -f docker-compose.exporters.yml
EXPORTER_SERVICES := node_exporter cadvisor

COMPOSE_ALL_FILES := ${COMPOSE_MONITORING} ${COMPOSE_EXPORTERS}
ALL_SERVICES := ${MONITORING_SERVICES} ${EXPORTER_SERVICES}

.PHONY: setup all up down stop restart rm images update

setup:    ## Build .env from config.d/*.env files
ifdef CLEAN
	@set -a && source ./config.d/dockprom.env &&	set +a && \
  for f in ./config.d/*.env; do set -a && source "$$f" &&	set +; done && \
  env|sort > .env
else
	@env -i PATH="$$PATH" CLEAN=1 sh -c "make setup"
endif

all:		## 'Start' Monitoring, and all applicable components - 'docker-compose ... up -d'
	docker-compose ${COMPOSE_ALL_FILES} up -d --build ${ALL_SERVICES}

up:   ## 'Up' Monitoring, and all applicable components - 'docker-compose ... up -d'
	@make all

down:   ## 'Down' Monitoring, and all applicable components - 'docker-compose ... down'
	docker-compose ${COMPOSE_ALL_FILES} down

stop:			## 'Stop' Monitoring, and all applicable components - 'docker-compose ... stop'
	@docker-compose ${COMPOSE_ALL_FILES} stop ${ALL_SERVICES}
	
restart:			## 'Restart' Monitoring, and all applicable components - 'docker-compose ... up -d'
	@docker-compose ${COMPOSE_ALL_FILES} restart ${ALL_SERVICES}

rm:			## 'Remove' Monitoring, and all applicable components - 'docker-compose ... rm =f'
	@docker-compose ${COMPOSE_ALL_FILES} rm -f ${ALL_SERVICES}

images:			## 'Show' Monitoring, and all applicable components - 'docker-compose ... images'
	@docker-compose ${COMPOSE_ALL_FILES} images ${ALL_SERVICES}

update:			## 'Update' Monitoring, and all applicable components - 'docker-compose ... pull/up'
	@docker-compose ${COMPOSE_ALL_FILES} pull
	@make all

# --------------------------
help:       	## Show this 'help'
	@echo "Make Application Docker Images and Containers using Docker-Compose files in 'docker' Dir."
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m (default: help)\n\nTargets:\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-12s\033[0m %s\n", $$1, $$2 }' $(MAKEFILE_LIST)
