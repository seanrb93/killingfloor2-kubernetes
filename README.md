# Killing Floor 2 Dedicated Server via Kubernetes

Run a **Killing Floor 2** dedicated server on a Kubernetes cluster using the manifests in this repository. This project includes:

- Kubernetes YAML to deploy the KF2 server, expose game ports, and provide WebAdmin access
- A persistent volume claim to keep server data across pod restarts
- Terraform (GCP) to provision supporting infrastructure (see `terraform/gcp`)

## Repository layout

- `kubernetes/`
  - `namespace-killingfloor2.yaml` — Creates the `killingfloor2` namespace
  - `kf2-deployment.yaml` — Deploys the KF2 server workload (pod spec, volume mounts, etc.)
  - `kf2-pvc.yaml` — PersistentVolumeClaim used by the server for durable data (configs/saves/logs depending on image)
  - `kf2-game.yaml` — Service manifest for the **game server** ports (UDP/TCP as required)
  - `kf2-webadmin.yaml` — Service manifest for **WebAdmin** access
- `terraform/`
  - `gcp/` — Terraform configuration for Google Cloud Platform resources (cluster/network/storage, depending on what you define there)

## Prerequisites

- A working Kubernetes cluster (local or cloud)
- `kubectl` configured to talk to your cluster
- StorageClass available in the cluster (for the PVC)
- (Optional) Terraform + credentials if you’re using the `terraform/gcp` configs

## Quick start (Kubernetes)

1. **Create the namespace**
   ```bash
   kubectl apply -f kubernetes/namespace-killingfloor2.yaml
   ```

2. **Create persistent storage**
   ```bash
   kubectl apply -f kubernetes/kf2-pvc.yaml
   ```

3. **Deploy the server**
   ```bash
   kubectl apply -f kubernetes/kf2-deployment.yaml
   ```

4. **Expose the game server and WebAdmin**
   ```bash
   kubectl apply -f kubernetes/kf2-game.yaml
   kubectl apply -f kubernetes/kf2-webadmin.yaml
   ```

5. **Check status**
   ```bash
   kubectl -n killingfloor2 get all
   kubectl -n killingfloor2 get pods
   ```

## Accessing the server

### Game server
The game server Service in `kubernetes/kf2-game.yaml` exposes the ports needed for clients to connect (typically UDP). How you connect depends on your cluster:

- **Cloud cluster**: if the Service is `LoadBalancer`, use the external IP.
- **Bare metal / homelab**: you may need MetalLB or NodePort and open firewall rules accordingly.

Check the service details:
```bash
kubectl -n killingfloor2 get svc
kubectl -n killingfloor2 describe svc <kf2-game-service-name>
```

### WebAdmin
The WebAdmin Service in `kubernetes/kf2-webadmin.yaml` exposes the admin UI. You can reach it via:

- External IP (LoadBalancer), or
- Port-forwarding for quick access:
  ```bash
  kubectl -n killingfloor2 port-forward svc/<kf2-webadmin-service-name> 8080:<service-port>
  ```
  Then open `http://localhost:8080`.

## Configuration

This repository provides the base manifests, but you will likely want to customize:

- Container image and version (in `kf2-deployment.yaml`)
- Environment variables / server settings (server name, admin password, etc.)
- Resource requests/limits
- Service type (ClusterIP / NodePort / LoadBalancer)
- Storage size/class in `kf2-pvc.yaml`

Search and edit values in:
- `kubernetes/kf2-deployment.yaml`
- `kubernetes/kf2-pvc.yaml`
- `kubernetes/kf2-game.yaml`
- `kubernetes/kf2-webadmin.yaml`

## Terraform (GCP)

If you want to provision infrastructure on Google Cloud:
- Terraform configuration lives under `terraform/gcp`.

General workflow (exact modules/variables depend on what’s defined there):
```bash
cd terraform/gcp
terraform init
terraform plan
terraform apply
```
