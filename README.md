# Local Kind Kubernetes Lab

Reproducible local Kubernetes environment built with Kind, designed to simulate a multi-node cluster for development, testing, and DevOps workflows.

## Why This Project

Local Kubernetes environments are often inconsistent across machines.

This project provides an automated, repeatable cluster setup that can be created and destroyed quickly without requiring a global Kind installation.

## Key Features

- Multi-node Kubernetes cluster
- 1 control-plane node and 2 worker nodes
- Automated lifecycle with Makefile
- Pinned Kind and Kubernetes node versions
- Self-contained tooling under `./bin`
- Ingress-ready configuration with ports `80` and `443`
- Local Docker image loading support

## Tech Stack

- Kubernetes
- Kind
- Docker
- Make
- kubectl
- ingress-nginx

## Quick Start

```bash
git clone <this-repo-url>
cd local-kind-k8s-lab
make up
```

Verify the cluster:

```bash
make status
```

## Make Commands

```bash
make tools     # download kind locally
make up        # create the cluster
make down      # delete the cluster
make recreate  # recreate the cluster
make status    # show cluster status
make ingress   # install ingress-nginx
make demo      # deploy a test nginx workload
make clean     # remove cluster and local binaries
```

## Cluster Configuration

The cluster is defined in `kind-config.yaml`:

- Cluster name: `dev`
- kubectl context: `kind-dev`
- 1 control-plane node
- 2 worker nodes
- Control-plane node labeled `ingress-ready=true`
- Host ports `80` and `443` mapped to localhost

## Common Usage

Switch to the cluster context:

```bash
kubectl config use-context kind-dev
```

List nodes:

```bash
kubectl get nodes
```

Load a locally built image into the cluster:

```bash
./bin/kind load docker-image my-app:dev --name dev
```

Install ingress-nginx:

```bash
make ingress
```

## DevOps Concepts Demonstrated

- Infrastructure as Code
- Reproducible local environments
- Kubernetes cluster automation
- Developer platform tooling
- Makefile-based workflow automation
- Local container image testing
- Ingress-ready Kubernetes setup

## Requirements

- Docker
- kubectl
- make
- curl

Docker must be running, and your user should be able to run Docker commands without `sudo`.

## Cleanup

```bash
make clean
```
