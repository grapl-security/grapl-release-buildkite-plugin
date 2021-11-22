COMPOSE_USER=$(shell id -u):$(shell id -g)

RUN_CHECK := docker-compose run --rm --user=${COMPOSE_USER}

.DEFAULT_GOAL=all

# Formatting
########################################################################

.PHONY: format
format: format-shell

.PHONY: format-shell
format-shell:
	./pants fmt ::

# Linting
########################################################################

.PHONY: lint
lint: lint-shell lint-plugin

.PHONY: lint-shell
lint-shell:
	./pants filter --target-type=shell_sources,shunit2_tests :: | xargs ./pants lint

.PHONY: lint-plugin
lint-plugin:
	${RUN_CHECK} plugin-linter

# Testing
########################################################################
.PHONY: test
test: test-shell

.PHONY: test-shell
test-shell:
	./pants test ::

########################################################################

.PHONY: all
all: format lint test
