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
  description = "GCP zone for the GKE cluster"
  type        = string
  default     = "europe-west2-a"
}

variable "cluster_name" {
  description = "GKE cluster name"
  type        = string
  default     = "kf2-gke"
}
