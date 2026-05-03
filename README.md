# Local Kind Kubernetes Lab

Reproducible local Kubernetes environment built with Kind (Kubernetes in Docker), designed for development, testing, and DevOps workflows.

## Why This Project

Local Kubernetes environments are often inconsistent across machines.

This project provides a predictable, automated cluster setup that can be created and destroyed quickly, with no global dependencies and fully pinned versions.

## Key Features

- Multi-node Kubernetes cluster (1 control-plane, 2 workers)
- Fully reproducible (pinned Kind and node versions)
- Automated lifecycle using Makefile
- No global installs (kind is managed locally)
- Ingress-ready (ports 80/443 mapped to localhost)
- Local Docker image loading support
- Safe context handling for kubectl commands

## Tech Stack

- Kubernetes
- Kind
- Docker
- Make
- kubectl
- ingress-nginx

## Requirements

- Docker (daemon must be running)
- kubectl
- make
- curl

Your user must be able to run Docker without sudo.

## Quick Start

```bash
git clone <this-repo-url>
cd local-kind-k8s-lab

make up
```

Verify cluster:

```bash
make status
```

## Make Commands

```bash
make preflight   # validate environment (docker, kubectl, curl)
make tools       # download kind locally
make up          # create cluster
make down        # delete cluster
make recreate    # reset cluster
make status      # full cluster status
make check       # quick health check
make ingress     # install ingress-nginx
make demo        # deploy test workload
make clean       # cleanup cluster and binaries
```

## Configuration

Cluster configuration is defined in `kind-config.yaml`.

- Cluster name: `dev`
- kubectl context: `kind-dev`
- 1 control-plane node
- 2 worker nodes
- Control-plane labeled for ingress
- Ports 80 and 443 mapped to localhost

## Usage Examples

Switch to cluster:

```bash
kubectl config use-context kind-dev
```

List nodes:

```bash
kubectl get nodes
```

Load local image into cluster:

```bash
./bin/kind load docker-image my-app:dev --name dev
```

Install ingress controller:

```bash
make ingress
```

## DevOps Concepts Demonstrated

- Infrastructure as Code
- Reproducible environments
- Local-first development workflows
- Kubernetes cluster automation
- Developer platform tooling
- Makefile-based automation
- Safe environment handling (context pinning)
- Fail-fast scripting practices

## Design Notes

- kubectl is always pinned to the cluster context to prevent accidental execution on other clusters
- Kind binary is version-pinned and locally managed for reproducibility
- Preflight checks ensure environment consistency before cluster creation
- Makefile uses strict shell flags for fail-fast execution

## Cleanup

```bash
make clean
```
