GITHUB_REPO ?= $(shell basename "$$(git rev-parse --show-toplevel)")
GITHUB_BRANCH ?= main
VISIBILITY ?= public

.PHONY: gh.create gh.protect gh.protect-status gh.var gh.vlist

gh.create: ## Crée le dépôt GitHub et pousse le dépôt local
	@echo "Création du dépôt GitHub : $(GITHUB_REPO)"
	@gh repo create "$(GITHUB_REPO)" \
		--$(VISIBILITY) \
		--source=. \
		--push

gh.protect: ## Protège la branche main et impose les Pull Requests
	@echo "Protection de la branche $(GITHUB_BRANCH)"
	@printf '%s\n' \
		'{"required_status_checks":null,"enforce_admins":true,"required_pull_request_reviews":{"dismiss_stale_reviews":true,"require_code_owner_reviews":false,"required_approving_review_count":0,"require_last_push_approval":false},"restrictions":null,"required_linear_history":false,"allow_force_pushes":false,"allow_deletions":false,"block_creations":false,"required_conversation_resolution":false,"lock_branch":false,"allow_fork_syncing":false}' \
		| gh api \
			--method PUT \
			"repos/{owner}/{repo}/branches/$(GITHUB_BRANCH)/protection" \
			--input -
	@echo "Branche $(GITHUB_BRANCH) protégée."

gh.protect-status: ## Affiche la protection de la branche main
	@gh api "repos/{owner}/{repo}/branches/$(GITHUB_BRANCH)/protection"

gh.var: ## Ajoute ou met à jour une variable GitHub
	@gh variable set "$(VAR_KEY)" --body "$(VAR_VALUE)"

gh.vlist: ## Liste les variables GitHub
	@gh variable list
