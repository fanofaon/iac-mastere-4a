GITHUB_REPO ?= $(shell basename "$$(git rev-parse --show-toplevel)")
VISIBILITY ?= public

.PHONY: gh.create gh.var gh.vlist

gh.create: ## Crée le dépôt GitHub et pousse le dépôt local
	@echo "Création du dépôt GitHub : $(GITHUB_REPO)"
	@gh repo create "$(GITHUB_REPO)" \
		--$(VISIBILITY) \
		--source=. \
		--push

gh.var: ## Ajoute une variable GitHub
	@gh variable set "$(VAR_KEY)" --body "$(VAR_VALUE)"

gh.vlist: ## Liste les variables GitHub
	@gh variable list
