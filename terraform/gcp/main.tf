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

provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
  default     = "europe-west1"
}

variable "zone" {
  description = "GCP zone"
  type        = string
  default     = "europe-west1-b"
}

variable "cluster_name" {
  description = "GKE cluster name"
  type        = string
  default     = "kf2-gke"
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

  release_channel {
    channel = "REGULAR"
  }

  depends_on = [google_project_service.container]
  
}

resource "google_container_node_pool" "kf2_nodes" {
  name       = "${var.cluster_name}-pool"
  location   = google_container_cluster.kf2_cluster.location
  cluster    = google_container_cluster.kf2_cluster.name

  autoscaling {
    min_node_count = 1
    max_node_count = 3
  }

  node_config {
    machine_type = "e2-small"

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]

    tags = ["kf2-node"]

  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }

}

output "cluster_name" {
  value = google_container_cluster.kf2.name
}

output "cluster_location" {
  value = google_container_cluster.kf2.location
}
