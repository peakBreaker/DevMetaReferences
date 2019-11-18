
provider "google" {
  // credentials = "${file("service-account.json")}"
  project = "${var.project}"
  region  = "${var.location}"
  // zone        = "${var.zone}"
}

module "myKubernetes" {
  source = "./1_kubernetes_up"

  // Variables to specify
  name = "${var.name}"
}
