locals {
  repository_host = "${var.gar_repository_location}-docker.pkg.dev"
  repository_name = "${local.repository_host}/${var.project_id}/${var.gar_repository_id}"
}