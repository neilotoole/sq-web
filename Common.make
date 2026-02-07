# -----------------------------------------------------------------------------------------------------------
# Common Makefile for sq-web (Hugo static site)
# Version: 2.0
# -----------------------------------------------------------------------------------------------------------
# This Makefile provides Docker-based local testing for the Hugo static site.
# Uses Dockerfile directly (no docker-compose required).
#
# Usage:
#   make <command>
#
# Available Commands:
#   help                    : Show this help message
#   build                   : Build the Docker image
#   check                   : Verify required tools (Bun, Hugo, Docker)
#   clean                   : Clean build artifacts and Docker resources
#   down                    : Stop and remove the container
#   logs                    : Show container logs
#   ping                    : Check if the site is running
#   run                     : Build and run the site locally (foreground)
#   run-detached            : Build and run the site in background
#   test                    : Run linting tests via Bun
#
# -----------------------------------------------------------------------------------------------------------

# Default target
all: help

# -----------------------------------------------------------------------------------------------------------
# Configuration
# -----------------------------------------------------------------------------------------------------------

# Project name (used for Docker image/container naming)
PROJECT_NAME := sq-web

# Docker image and container names
DOCKER_IMAGE := $(PROJECT_NAME):latest
DOCKER_CONTAINER := $(PROJECT_NAME)-local

# Port mapping (host:container)
HOST_PORT := 8080
CONTAINER_PORT := 80

# Default shell to use
SHELL := /bin/bash

# Import so we can use the log functions
LOGGER := source scripts/log.bash &&


# -----------------------------------------------------------------------------------------------------------
# Help (default target)
# -----------------------------------------------------------------------------------------------------------

.PHONY: help build check clean run run-detached down logs test ping

.PHONY: help ## Show this help message
help:
	@$(LOGGER) log_banner
	@$(LOGGER) log_info "Available make targets:"
	@echo ""
	@grep -E \
		'^.PHONY: .*?## .*$$' $(MAKEFILE_LIST) | \
		sort | \
		awk 'BEGIN {FS = ".PHONY: |## "}; {printf " %-22s$(RESET) $(DIM)- %s$(RESET)\n", $$2, $$3}'
		@echo ""
	@$(LOGGER) log_info "Quick start"
	@echo " make run-detached && make ping"
	@echo ""
	@$(LOGGER) log_dim "Site will be available at http://localhost:$(HOST_PORT)"


# -----------------------------------------------------------------------------------------------------------
# Check environment
# -----------------------------------------------------------------------------------------------------------

# Check if Bun is installed
check_bun:
	@if command -v bun >/dev/null 2>&1; then \
		BUN_VERSION=$$(bun --version); \
		$(LOGGER) log_info_dim "Bun $$BUN_VERSION is installed."; \
	else \
		$(LOGGER) log_error "Bun is not installed. Install: curl -fsSL https://bun.sh/install | bash"; \
		exit 1; \
	fi

# Check if Hugo is installed (via node_modules or system)
check_hugo:
	@if [ -x "node_modules/.bin/hugo/hugo" ]; then \
		HUGO_VERSION=$$(node_modules/.bin/hugo/hugo version 2>/dev/null | grep -o 'v[0-9.]*' | head -1); \
		$(LOGGER) log_info_dim "Hugo $$HUGO_VERSION is installed (via node_modules)."; \
	elif command -v hugo >/dev/null 2>&1; then \
		HUGO_VERSION=$$(hugo version 2>/dev/null | grep -o 'v[0-9.]*' | head -1); \
		$(LOGGER) log_info_dim "Hugo $$HUGO_VERSION is installed (system)."; \
	else \
		$(LOGGER) log_warning "Hugo not found. Run 'bun install' to install via hugo-installer."; \
	fi

# Check if Docker is installed (required for Docker targets)
check_docker:
	@if command -v docker >/dev/null 2>&1; then \
		DOCKER_VERSION=$$(docker --version | sed 's/Docker version //' | cut -d',' -f1); \
		$(LOGGER) log_info_dim "Docker $$DOCKER_VERSION is installed."; \
	else \
		$(LOGGER) log_error "Docker is not installed. Required for Docker targets."; \
		exit 1; \
	fi

# Check all dependencies
check_deps:
	@$(LOGGER) log_separator
	@$(LOGGER) log_info "Checking Dependencies"
	@$(MAKE) check_docker
	@$(MAKE) check_bun
	@$(MAKE) check_hugo


.PHONY: check ## Verify required tools are installed
check: check_deps


# -----------------------------------------------------------------------------------------------------------
# Docker targets (using Dockerfile directly)
# -----------------------------------------------------------------------------------------------------------

.PHONY: build ## Build the Docker image
build: check
	@$(LOGGER) log_separator
	@$(LOGGER) log_info "Building Docker image: $(DOCKER_IMAGE)"
	docker build -t $(DOCKER_IMAGE) .
	@$(LOGGER) log_success "Docker image built successfully"

.PHONY: run ## Build and run the site locally (foreground)
run: check_docker
	@$(LOGGER) log_separator
	@$(LOGGER) log_info "Building and starting $(PROJECT_NAME) container"
	@$(LOGGER) log_info "Site will be available at http://localhost:$(HOST_PORT)"
	@$(LOGGER) log_dim "Press Ctrl+C to stop"
	@# Stop any existing container first
	@docker stop $(DOCKER_CONTAINER) 2>/dev/null || true
	@docker rm $(DOCKER_CONTAINER) 2>/dev/null || true
	@# Build and run in foreground
	docker build -t $(DOCKER_IMAGE) . && \
	docker run --rm --name $(DOCKER_CONTAINER) -p $(HOST_PORT):$(CONTAINER_PORT) $(DOCKER_IMAGE)

.PHONY: run-detached ## Build and run the site in background
run-detached: check_docker
	@$(LOGGER) log_separator
	@$(LOGGER) log_info "Building and starting $(PROJECT_NAME) container (detached)"
	@# Stop any existing container first
	@docker stop $(DOCKER_CONTAINER) 2>/dev/null || true
	@docker rm $(DOCKER_CONTAINER) 2>/dev/null || true
	@# Build and run in background
	docker build -t $(DOCKER_IMAGE) .
	docker run -d --name $(DOCKER_CONTAINER) -p $(HOST_PORT):$(CONTAINER_PORT) $(DOCKER_IMAGE)
	@$(LOGGER) log_success "Container started in background"
	@$(LOGGER) log_info "Site available at http://localhost:$(HOST_PORT)"
	@$(LOGGER) log_dim "Use 'make logs' to view logs, 'make down' to stop"

.PHONY: logs ## Show container logs
logs:
	@$(LOGGER) log_separator
	@$(LOGGER) log_info "Showing logs for $(DOCKER_CONTAINER)"
	@$(LOGGER) log_dim "Press Ctrl+C to exit"
	@docker logs -f $(DOCKER_CONTAINER) || $(LOGGER) log_error "Container not running"

.PHONY: down ## Stop and remove the container
down:
	@$(LOGGER) log_separator
	@$(LOGGER) log_info "Stopping $(PROJECT_NAME) container..."
	@docker stop $(DOCKER_CONTAINER) 2>/dev/null || true
	@docker rm $(DOCKER_CONTAINER) 2>/dev/null || true
	@$(LOGGER) log_success "Container stopped and removed"

.PHONY: clean ## Clean build artifacts and Docker resources
clean:
	@$(LOGGER) log_separator
	@$(LOGGER) log_info "Cleaning project build artifacts and Docker resources"
	@$(LOGGER) log_indent log_dim "Stopping and removing container..."
	@docker stop $(DOCKER_CONTAINER) 2>/dev/null || true
	@docker rm $(DOCKER_CONTAINER) 2>/dev/null || true
	@$(LOGGER) log_indent log_dim "Removing Docker image..."
	@docker rmi $(DOCKER_IMAGE) 2>/dev/null || true
	@$(LOGGER) log_indent log_dim "Removing Hugo build artifacts..."
	@rm -rf public resources .hugo_build.lock
	@$(LOGGER) log_success "Clean complete"


# -----------------------------------------------------------------------------------------------------------
# Testing and health check
# -----------------------------------------------------------------------------------------------------------

.PHONY: test ## Run linting tests via Bun
test:
	@$(LOGGER) log_separator
	@$(LOGGER) log_info "Running tests (bun run test)"
	bun run test

.PHONY: ping ## Check if the site is running
ping:
	@$(LOGGER) log_separator
	@$(LOGGER) log_info "Checking health of $(PROJECT_NAME)"
	@echo ""
	@echo -e "  • Hugo Site $(DIM)(nginx)$(RESET) $(BLUE)[http://localhost:$(HOST_PORT)]$(RESET)"
	@if curl -s http://localhost:$(HOST_PORT) >/dev/null 2>&1; then \
		$(LOGGER) log_indent log_success "Site is healthy"; \
	else \
		$(LOGGER) log_indent log_error "Site is not responding"; \
	fi
	@echo ""
	@$(LOGGER) log_info "Health check complete"
