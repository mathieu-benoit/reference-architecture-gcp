output "gar_repository_id" {
  description = "Google Artifact Registry repository id (if created)."
  value       = module.k8s.gar_repository_id
}

output "operator_public_key" {
  value = tls_private_key.operator.public_key_pem
}