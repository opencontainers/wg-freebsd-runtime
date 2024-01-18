DOCKER ?= $(shell command -v docker 2>/dev/null)
MARKDOWN_LINT_VER?=latest

default: lint

.PHONY: lint
lint: lint-md ## Run all linters

.PHONY: lint-md
lint-md: ## Run linting for markdown
	docker run --rm -v "$(PWD):/workdir:ro" docker.io/davidanson/markdownlint-cli2:$(MARKDOWN_LINT_VER) \
	  "**/*.md"

.PHONY: help
help: # Display help
	@awk -F ':|##' '/^[^\t].+?:.*?##/ { printf "\033[36m%-30s\033[0m %s\n", $$1, $$NF }' $(MAKEFILE_LIST)
