# Local Development with k3d

This is a repo with examples for getting a k3d development environment up and running with minimal fuss.


>## :warning: **This repo contains hard-coded passwords**
> 
> This is intended for local development only, if you plan to migrate to using any parts of this in a production scenario, take care to remove hard-coded passwords and consider a more secure approach such as dynamically generated passwords!

## Services

* Postgresql with multiple databases
* Redis
* Seq logging service
* [Nginx ingress controller](https://kubernetes.github.io/ingress-nginx)
* Whoami service, loading configuration from ConfigMaps
* Reloader for triggered deployment restarts
* ArgoCD

## Requirements

* docker
* terraform
* k3d
* k9s
* argocd-cli

## Usage

It utilises the `localtest.me` domain and exposes services at the followng end points:

| external address | cluster address | namespace | credentials |
| -- | -- | -- | -- |
| seq.localtest.me | seq.seq.svc.cluster.local | seq | admin/seq4all |
| development.localtest.me | app.development.svc.cluster.local | development | n/a |
| staging.localtest.me | app.staging.svc.cluster.local | staging | n/a |
| production.localtest.me | app.production.svc.cluster.local | production | n/a |

The following additional TCP ports are exposed for the ease of development and testing:

| external port | cluster address | namespace | credentials |
| -- | -- | -- | -- |
| tcp/6379 | redis-master.redis.svc.cluster.local | redis | secrets: redis-secrets | 
| tcp/5432 | postgres-postgresql.postgres.svc.cluster.local | postgres | secrets: postgres-secrets |

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
2. `kubectl --context k3d-dev apply -f .`

``` bash
REPO=git@github.com:{UserName}/{RepoName}.git

argocd login argocd.localtest.me
argocd repo add $REPO --ssh-private-key-path ~/.ssh/argocd

argocd app create api-development --repo $REPO --path api/environments/development --dest-server https://kubernetes.default.svc --dest-namespace development
argocd app create api-staging --repo $REPO --path api/environments/staging --dest-server https://kubernetes.default.svc --dest-namespace staging
argocd app create api-production --repo $REPO --path api/environments/production --dest-server https://kubernetes.default.svc --dest-namespace production

argocd app sync --project default

http://whoami.development.localtest.me/
```

You can now access your cluster using kubectl or k9s

```
kubectl --context k3d-dev ...
```

or

```
brew install k9s
k9s --context k3d-dev
```

## TODO / Future Work


###  ArgoCD
https://argoproj.github.io/

kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

### Devspace

https://www.devspace.sh/#ui
