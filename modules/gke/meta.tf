data "google_client_config" "default" {}

data "google_project" "project" {}

data "http" "icanhazip" {
  url = "http://icanhazip.com"
}
