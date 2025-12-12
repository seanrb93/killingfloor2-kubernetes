resource "google_project_iam_member" "gke_lb_admin" {
  project = var.project_id
  role    = "roles/compute.loadBalancerAdmin"

  member = "serviceAccount:service-${data.google_project.this.number}@container-engine-robot.iam.gserviceaccount.com"
}