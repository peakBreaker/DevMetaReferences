resource "google_container_cluster" "default" {
  name        = "${var.name}-cluster"
  description = "Demo GKE Cluster"

  # We want to set up our own node pool
  remove_default_node_pool = true
  initial_node_count       = "${var.initial_node_count}"

}

resource "google_container_node_pool" "default" {
  name       = "${var.name}-node-pool"
  cluster    = "${google_container_cluster.default.name}"
  node_count = 1

  node_config {
    preemptible  = true
    machine_type = "${var.machine_type}"

    metadata = {
      disable-legacy-endpoints = "true"
    }

    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
  }
}
