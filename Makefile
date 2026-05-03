SHELL := /bin/bash
.SHELLFLAGS := -eu -o pipefail -c

# ---- Configuration ----
CLUSTER_NAME ?= dev
KIND_CONFIG  ?= kind-config.yaml
KIND_VERSION ?= v0.24.0

# ---- Binaries ----
KIND    ?= ./bin/kind
KUBECTL ?= kubectl

# Always pin kubectl to this cluster context to avoid running commands
# against the wrong Kubernetes cluster.
KUBECTL_CTX := kind-$(CLUSTER_NAME)

# Detect host OS/arch so the correct kind binary is downloaded.
# Override when needed, for example:
# make tools ARCH=arm64
OS   := $(shell uname | tr '[:upper:]' '[:lower:]')
ARCH ?= amd64

.PHONY: help preflight tools up down recreate status check kubeconfig ingress demo clean

help: ## Show this help
	@awk 'BEGIN {FS = ":.*##"; printf "Usage: make <target>\n\nTargets:\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-12s\033[0m %s\n", $$1, $$2 }' $(MAKEFILE_LIST)

preflight: ## Check required tools are installed
	@command -v docker >/dev/null 2>&1 || { echo "docker is required"; exit 1; }
	@command -v $(KUBECTL) >/dev/null 2>&1 || { echo "kubectl is required"; exit 1; }
	@command -v curl >/dev/null 2>&1 || { echo "curl is required"; exit 1; }
	@docker info >/dev/null 2>&1 || { echo "Docker daemon is not running or permission is denied"; exit 1; }

tools: ## Install the kind binary into ./bin
	@mkdir -p ./bin
	@if [ ! -x $(KIND) ]; then \
		echo "Downloading kind $(KIND_VERSION) for $(OS)/$(ARCH)..."; \
		curl -fsSLo $(KIND) https://kind.sigs.k8s.io/dl/$(KIND_VERSION)/kind-$(OS)-$(ARCH); \
		chmod +x $(KIND); \
	fi
	@$(KIND) version

up: preflight tools ## Create the kind cluster and wait until all nodes are Ready
	$(KIND) create cluster --name $(CLUSTER_NAME) --config $(KIND_CONFIG) --wait 120s
	@echo "Waiting for all nodes to become Ready..."
	$(KUBECTL) --context $(KUBECTL_CTX) wait --for=condition=Ready nodes --all --timeout=120s
	@echo
	@echo "Cluster ready. Try: make status"

down: tools ## Delete the kind cluster
	$(KIND) delete cluster --name $(CLUSTER_NAME)

recreate: down up ## Delete and recreate the cluster

status: ## Show cluster info, nodes, and all pods
	$(KUBECTL) --context $(KUBECTL_CTX) cluster-info
	$(KUBECTL) --context $(KUBECTL_CTX) get nodes -o wide
	$(KUBECTL) --context $(KUBECTL_CTX) get pods -A

check: ## Quick health check
	$(KUBECTL) --context $(KUBECTL_CTX) get nodes
	@echo
	$(KUBECTL) --context $(KUBECTL_CTX) -n kube-system get pods

kubeconfig: tools ## Print the kubeconfig for this cluster
	$(KIND) get kubeconfig --name $(CLUSTER_NAME)

ingress: ## Install ingress-nginx
	$(KUBECTL) --context $(KUBECTL_CTX) apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.11.2/deploy/static/provider/kind/deploy.yaml
	$(KUBECTL) --context $(KUBECTL_CTX) -n ingress-nginx wait --for=condition=ready pod \
		--selector=app.kubernetes.io/component=controller --timeout=180s

demo: ## Deploy a small nginx workload
	@if $(KUBECTL) --context $(KUBECTL_CTX) get deployment hello >/dev/null 2>&1; then \
		echo "Deployment 'hello' already exists, skipping create"; \
	else \
		$(KUBECTL) --context $(KUBECTL_CTX) create deployment hello --image=nginx:alpine; \
	fi
	@if $(KUBECTL) --context $(KUBECTL_CTX) get service hello >/dev/null 2>&1; then \
		echo "Service 'hello' already exists, skipping expose"; \
	else \
		$(KUBECTL) --context $(KUBECTL_CTX) expose deployment hello --port=80 --type=ClusterIP; \
	fi
	$(KUBECTL) --context $(KUBECTL_CTX) rollout status deployment/hello

clean: down ## Remove the cluster and downloaded tools
	rm -rf ./bin

