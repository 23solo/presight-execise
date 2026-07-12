.PHONY: up setup down help

# Prefer the root Makefile for the full app. These targets stay for server-only work.
up setup down:
	@$(MAKE) -C .. $@

help:
	@echo "Use the repo root Makefile:"
	@echo "  cd .. && make up"
	@echo "  cd .. && make help"
