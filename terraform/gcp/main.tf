terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "7.13.0"
    }
  }

  required_version = ">= 1.6.0"
  
  backend "gcs" {
    bucket = "tfstate-kf2-gke"
    prefix = "kf2/terraform/state"
    
  }
}

data "google_project" "this" {
  project_id = var.project_id
}

provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

resource "google_project_iam_member" "gke_lb_admin" {
  project = var.project_id
  role    = "roles/compute.loadBalancerAdmin"

  member = "serviceAccount:service-${data.google_project.this.number}@container-engine-robot.iam.gserviceaccount.com"
}

resource "google_project_service" "container" {
  project = var.project_id
  service = "container.googleapis.com"
  disable_on_destroy = false
}

resource "google_container_cluster" "kf2_cluster" {
  name     = var.cluster_name
  location = var.zone

  remove_default_node_pool = true
  initial_node_count       = 1

  networking_mode = "VPC_NATIVE"

  ip_allocation_policy {}

  depends_on = [google_project_service.container]
  deletion_protection = false
  
}

resource "google_container_node_pool" "kf2_nodes" {
  name       = "primary-pool"
  location   = var.zone
  cluster    = google_container_cluster.kf2_cluster.name
  node_count = var.node_count

  node_config {
    machine_type = var.node_machine_type

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]

    tags = ["kf2-node"]

  }

}

output "cluster_name" {
  value = google_container_cluster.kf2_cluster.name
}

output "region" {
  value = var.region
}

output "zone" {
  value = var.zone
}

output "project_id" {
  value = var.project_id
}