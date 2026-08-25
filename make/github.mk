GITHUB_REPO ?= $(shell basename "$$(git rev-parse --show-toplevel)")
GITHUB_OWNER ?= $(shell gh api user --jq .login 2>/dev/null)
GITHUB_SLUG ?= $(GITHUB_OWNER)/$(GITHUB_REPO)
GITHUB_BRANCH ?= main
VISIBILITY ?= public

.PHONY: gh.create gh.protect gh.protect-status gh.pr.create gh.pr.merge gh.var gh.vlist

gh.create: ## Crée le dépôt GitHub et pousse le dépôt initial
	@if gh repo view "$(GITHUB_SLUG)" >/dev/null 2>&1; then \
		echo "Le dépôt GitHub $(GITHUB_SLUG) existe déjà."; \
	else \
		echo "Création du dépôt GitHub : $(GITHUB_SLUG)"; \
		gh config set git_protocol https --host github.com; \
		gh repo create "$(GITHUB_SLUG)" \
			--$(VISIBILITY) \
			--source=. \
			--remote=origin \
			--push; \
	fi

gh.protect: ## Protège main et impose les Pull Requests
	@echo "Protection de la branche $(GITHUB_BRANCH)"
	@printf '%s\n' \
		'{"required_status_checks":null,"enforce_admins":true,"required_pull_request_reviews":{"dismiss_stale_reviews":true,"require_code_owner_reviews":false,"required_approving_review_count":0,"require_last_push_approval":false},"restrictions":null,"required_linear_history":false,"allow_force_pushes":false,"allow_deletions":false,"block_creations":false,"required_conversation_resolution":false,"lock_branch":false,"allow_fork_syncing":false}' \
		| gh api \
			--method PUT \
			"repos/{owner}/{repo}/branches/$(GITHUB_BRANCH)/protection" \
			--input -
	@echo "Branche $(GITHUB_BRANCH) protégée."

gh.protect-status: ## Affiche l'état de protection de main
	@gh api \
		"repos/{owner}/{repo}/branches/$(GITHUB_BRANCH)/protection" \
		--jq '{require_pull_request: (.required_pull_request_reviews != null), enforce_admins: .enforce_admins.enabled, allow_force_pushes: .allow_force_pushes.enabled, allow_deletions: .allow_deletions.enabled, lock_branch: .lock_branch.enabled}'

gh.pr.create: ## Crée une Pull Request vers main
	@gh pr create --base "$(GITHUB_BRANCH)" --fill

gh.pr.merge: ## Fusionne la Pull Request courante et supprime sa branche
	@gh pr merge --merge --delete-branch

gh.var: ## Ajoute ou met à jour une variable GitHub
	@test -n "$(VAR_KEY)" || (echo "Usage: make gh.var VAR_KEY=KEY VAR_VALUE=VALUE" && exit 1)
	@gh variable set "$(VAR_KEY)" --body "$(VAR_VALUE)"

gh.vlist: ## Liste les variables GitHub
	@gh variable list
