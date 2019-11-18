### Basics

Terraform is an infrastructure management tool - great for setting up cloud
resources instead of using a console or the prodivded SDK.

Terraform configuration is divided into :

- Providers
- Resources
- Variables
- Outputs

#### Provider on GCP

This document is meant as a reference for common GCP things to do in Terraform.

Start off with a google provider config to let all GCP resources ba able to
pull the GCP configs from it (such as project id and location).
[Reference](https://www.terraform.io/docs/providers/google/index.html)

```
provider "google" {
  credentials = "${file("service-account.json")}"
  project     = "devopscube-demo"
  region      = "us-central1"
  zone        = "us-central1-c"
}
```

### Common GCP Resources

You can find resources on most things on GCP, though below are some of the
most common things I do and want to have a reference to:

#### Kubernetes Engine

Setting up a cluster and adding node pools are common things to do on GKE, and
nice to haves:

```
resource "google_container_cluster" "default" {
  name        = "${var.name}"
  project     = "${var.project}"
  description = "Demo GKE Cluster"
  location    = "${var.location}"

  remove_default_node_pool = true
  initial_node_count = "${var.initial_node_count}"

  master_auth {
    username = ""
    password = ""

    client_certificate_config {
      issue_client_certificate = false
    }
  }
}

resource "google_container_node_pool" "default" {
  name       = "${var.name}-node-pool"
  project     = "${var.project}"
  location   = "${var.location}"
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
```

location, project and name can be omitted if we have the google provider configured

#### [Access in GKE](https://www.terraform.io/docs/providers/google/d/datasource_google_service_account.html)

We can easily add a new serviceaccount and hook it to a GKE secret:

```
data "google_service_account" "myaccount" {
  account_id = "myaccount-id"
}

resource "google_service_account_key" "mykey" {
  service_account_id = data.google_service_account.myaccount.name
}

resource "kubernetes_secret" "google-application-credentials" {
  metadata {
    name = "google-application-credentials"
  }
  data = {
    credentials.json = base64decode(google_service_account_key.mykey.private_key)
  }
}
```

#### Storage buckets

```
resource "google_storage_bucket" "image-store" {
  name     = "image-store-bucket"
  location = "EU"
  retention_policy {
    is_locked = false
    retention_period = 302400 // One week in seconds
  }
}
```

Giving access to buckets can be found
[here](https://www.terraform.io/docs/providers/google/r/storage_bucket_access_control.html)


#### Pubsubs

[Reference](https://www.terraform.io/docs/providers/google/r/pubsub_subscription.html)

Pubs, easy :
```
resource "google_pubsub_topic" "example" {
  name = "example-topic"
}
```

Subs : 

```
resource "google_pubsub_subscription" "example" {
  name  = "example-subscription"
  topic = google_pubsub_topic.example.name

  ack_deadline_seconds = 20

  labels = {
    foo = "bar"
  }

  push_config {
    push_endpoint = "https://example.com/push"

    attributes = {
      x-goog-version = "v1"
    }
  }
}
```


#### KMS Keys

