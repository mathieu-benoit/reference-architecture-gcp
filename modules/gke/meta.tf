data "google_client_config" "default" {}

data "http" "icanhazip" {
  url = "http://icanhazip.com"
}
