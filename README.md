# Local Development with k3d

This is a repo with examples for getting a k3d development environment up and running with minimal fuss.

## Services

* Postgresql with multiple databases
* Redis
* Seq logging service
* Unleash feature management services
* [Nginx ingress controller](https://kubernetes.github.io/ingress-nginx)
* Reloader for triggered deployment restarts

## Requirements

* docker
* terraform
* k3d
* k9s

## Usage

It utilises the `localtest.me` domain and exposes services at the followng end points:

| external address | cluster address |
| -- | -- |
| seq.localtest.me | seq.seq.svc.cluster.local |
| n/a | postgres-postgresql.postgres.svc.cluster.local |
| development.localtest.me | app.development.svc.cluster.local |
| test.localtest.me | app.test.svc.cluster.local |
| production.localtest.me | app.production.svc.cluster.local |
| unleash.localtest.me | unleash.unleash.svc.cluster.local |

### Step 1. **k3d-cluster** Create a k3d Cluster

**This step simply creates an empty k3d cluster.**

*This step needs to be run separately because of the typical inception problem with creating resources with terraform and then having other resources requiring access to the metadata from the first one.  Because Terraform evaluates things at startup, this causes problems.*

1. `cd k3d-cluster`
2. `terraform init`
3. `terraform apply -auto-approve`

    
    ```
    ... after some seconds ...

    k3d_cluster.dev: Creation complete after 22s [id=dev]

    Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
    ```

Your k3d kubernetes cluster is now started.  You can confirm this by running `kubectl config get-clusters`


### Step 2. **k3d-dependencies** Install Dependencies and Services

**This step installs dependencies: ingress controller, postgres, seq, redis.**

1. `cd k3d-dependencies`
2. `terraform init`
3. `terraform apply -auto-approve`


### Step 3. **k3d-workloads** directory

1. `cd k3d-workload`
2. `terraform init`
3. `terraform apply -auto-approve`



## Install K9s 

brew install k9s
k9s --context k3d-dev

## ArgoCD
https://argoproj.github.io/

kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

https://www.devspace.sh/#ui
