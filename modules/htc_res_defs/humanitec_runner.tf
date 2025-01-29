resource "humanitec_resource_account" "terraform_provisioner_account" {
  id   = element(split("@", var.terraform_provisioner_gsa_email), 0)
  name = element(split("@", var.terraform_provisioner_gsa_email), 0)
  type = "gcp-identity"

  credentials = jsonencode({
    gcp_service_account = var.terraform_provisioner_gsa_email
    gcp_audience        = "//iam.googleapis.com/${var.gcp_wi_pool_provider_name}"
  })
}