.ONESHELL:
SHELL := /bin/bash
.SHELLFLAGS := -eu -o pipefail -c
.DEFAULT_GOAL := help

INFO_COLOR := \033[36;1m
UI_COLOR := \033[35;1m
ERROR_COLOR := \033[31;1m
SUCCESS_COLOR := \033[32;1m
RESET_COLOR := \033[m

.PHONY: help check-tools

check-tools: ## Vérifie les outils nécessaires au TP
	@for software in git gh; do \
		if command -v "$$software" >/dev/null 2>&1; then \
			echo -e "$(SUCCESS_COLOR)$$software présent$(RESET_COLOR)"; \
		else \
			echo -e "$(ERROR_COLOR)$$software absent$(RESET_COLOR)"; \
		fi; \
	done

help: ## Affiche l'aide
	@echo -e "\n$(UI_COLOR)================= MENU =================$(RESET_COLOR)\n"
	@grep -hE "^[a-zA-Z_.-]+:.*?## .*$$" $(MAKEFILE_LIST) | sort | \
		awk 'BEGIN {FS=":.*?##"}{printf "$(INFO_COLOR)%-20s$(RESET_COLOR)%s\n", $$1, $$2}'
	@echo -e "\n$(UI_COLOR)========================================$(RESET_COLOR)\n"
