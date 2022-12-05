# Bootstrap Flux

## 1. Install the Flux manifests into the cluster

```sh
kubectl apply --kustomize ./cluster/bootstrap
```

## 2. Apply Cluster Secrets and ConfigMaps needed before bootstrapping this Git Repository

_These cannot be applied with `kubectl` in the regular fashion due to be encrypted with sops_

```sh
sops --decrypt cluster/bootstrap/age-key.sops.yaml | kubectl apply -f -
sops --decrypt cluster/bootstrap/github-deploy-key.sops.yaml | kubectl apply -f -
sops --decrypt cluster/flux/vars/cluster-secrets.sops.yaml | kubectl apply -f -
kubectl apply -f cluster/flux/vars/cluster-settings.yaml
```

## 3. Apply the Flux CRs to bootstrap this Git repository into the cluster

```sh
kubectl apply --kustomize ./cluster/flux/config
```

## First Setup or Secret Rotation

### 1. Generate SSH Key for Git

GitHub reference: https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent#generating-a-new-ssh-key
```sh
ssh-keygen -t ed25519 -C $(git config user.email)
```

Upload the key to GitHub.

### 2. Generate Gpg Key with Age

Make sure [age](https://github.com/FiloSottile/age#installation) and [sops](https://github.com/mozilla/sops#id4) is installed.

```sh
mkdir -p ~/.sops
age-keygen -o ~/.sops/age.agekey
```

### 3. Create Bootstrap Encryption Secret

```sh
cat ~/.sops/age.agekey |
    kubectl create secret generic sops-age \
    --namespace=flux-system \
    --from-file=age.agekey=/dev/stdin \
    --dry-run=client \
    -o yaml > cluster/bootstrap/age-key.sops.yaml
```

**Encrypt sops using Age public key**
```sh
sops --age=PUBLIC_KEY --encrypt \
    --encrypted-regex  '^(data|stringData)$' \
    --in-place cluster/bootstrap/age-key.sops.yaml
```

### 4. Create Git Authentication Secret

```sh
ssh-keyscan -t ecdsa-sha2-nistp256 github.com > /tmp/know_hosts &&
kubectl create secret generic github-deploy-key \
    --namespace=flux-system \
    --from-file=identity=$HOME/.ssh/$KEY_NAME \
    --from-file=known_hosts=/tmp/know_hosts \
    --dry-run=client \
    -o yaml > cluster/bootstrap/github-deploy-key.sops.yaml
```

**Encrypt sops using Age public key**

```sh
sops --age=PUBLIC_KEY --encrypt \
    --encrypted-regex  '^(data|stringData)$' \
    --in-place cluster/bootstrap/github-deploy-key.sops.yaml
```

### 5. Configure the Cluster Secrets and Settings

```sh
vim cluster/flux/cluster-secrets.sops.yaml
vim cluster/flux/cluster-settings.sops.yaml
```

The cluster secrets should be encrypted:

```sh
sops --age=PUBLIC_KEY --encrypt \
    --encrypted-regex  '^(data|stringData)$' \
    --in-place cluster/flux/vars/cluster-secrets.sops.yaml
```

### 6. Bootstrap Cluster

Now run the commands on top of this file.
