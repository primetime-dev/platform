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

## Install the dashboard

```bash
./platform/bootstrap/install-dashboard.sh
```

The install script creates an `admin-user` service account and cluster role binding.

## Get a login token

```bash
kubectl -n kubernetes-dashboard create token admin-user
```

## Port-forward the dashboard

Use the service name printed by the install script. On current chart releases this is
typically:

```bash
kubectl -n kubernetes-dashboard port-forward svc/kubernetes-dashboard-kong-proxy 8443:443
```

If the chart changes in a later release, list the services and use the proxy service
it created:

```bash
kubectl -n kubernetes-dashboard get svc
```
