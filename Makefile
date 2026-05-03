CLUSTER_NAME ?= dev
KIND_CONFIG  ?= kind-config.yaml
KIND         ?= ./bin/kind
KUBECTL      ?= kubectl

.PHONY: help tools up down recreate status kubeconfig ingress demo clean

help: ## Show this help
	@awk 'BEGIN {FS = ":.*##"; printf "Usage: make <target>\n\nTargets:\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-12s\033[0m %s\n", $$1, $$2 }' $(MAKEFILE_LIST)

tools: ## Install the kind binary into ./bin
	@mkdir -p bin
	@if [ ! -x $(KIND) ]; then \
		echo "Downloading kind..."; \
		curl -fsSLo $(KIND) https://kind.sigs.k8s.io/dl/v0.24.0/kind-linux-amd64; \
		chmod +x $(KIND); \
	fi
	@$(KIND) version

up: tools ## Create the kind cluster
	$(KIND) create cluster --name $(CLUSTER_NAME) --config $(KIND_CONFIG) --wait 120s
	@echo
	@echo "Cluster ready. Try: make status"

down: ## Delete the kind cluster
	$(KIND) delete cluster --name $(CLUSTER_NAME)

recreate: down up ## Delete and recreate the cluster

status: ## Show cluster nodes and system pods
	$(KUBECTL) cluster-info --context kind-$(CLUSTER_NAME)
	$(KUBECTL) get nodes -o wide
	$(KUBECTL) get pods -A

kubeconfig: ## Print the kubeconfig for this cluster
	$(KIND) get kubeconfig --name $(CLUSTER_NAME)

ingress: ## Install ingress-nginx (matches the port mappings in kind-config.yaml)
	$(KUBECTL) apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.11.2/deploy/static/provider/kind/deploy.yaml
	$(KUBECTL) -n ingress-nginx wait --for=condition=ready pod \
		--selector=app.kubernetes.io/component=controller --timeout=180s

demo: ## Deploy a tiny nginx service to verify the cluster works
	$(KUBECTL) create deployment hello --image=nginx:alpine || true
	$(KUBECTL) expose deployment hello --port=80 --type=ClusterIP || true
	$(KUBECTL) rollout status deployment/hello

clean: down ## Remove the cluster and downloaded tools
	rm -rf bin

