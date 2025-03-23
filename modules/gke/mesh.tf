resource "google_gke_hub_feature" "gke_hub_feature" {
  name     = "servicemesh"
  location = "global"
}

resource "google_gke_hub_feature_membership" "gke_hub_feature_membership" {
  location            = "global"
  feature             = google_gke_hub_feature.gke_hub_feature.name
  membership          = google_container_cluster.gke.fleet.0.membership
  membership_location = google_container_cluster.gke.location
  mesh {
    management = "MANAGEMENT_AUTOMATIC"
  }
}