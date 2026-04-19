# Bootstrap

These scripts handle the light post-cluster setup for the demo environment.

## Prerequisites

- `kubectl`
- `helm`
- kubeconfig for the target cluster

## Apply namespaces

```bash
./platform/bootstrap/apply-namespaces.sh
```

## Install Headlamp

```bash
./platform/bootstrap/install-headlamp.sh
```

The install script creates an `admin-user` service account and cluster role binding.

## Get a login token

```bash
kubectl -n headlamp create token admin-user
```

## Port-forward Headlamp

Use the service name and port printed by the install script. On current chart releases
this is typically:

```bash
kubectl -n headlamp port-forward svc/headlamp 4466:80
```

Then open `http://localhost:4466`.

If the chart changes in a later release, list the services and use the Headlamp
service it created:

```bash
kubectl -n headlamp get svc
```
