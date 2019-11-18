
variable "name" {
  description = "The name identifier for the GKE resources created"
  type        = string
}

variable "initial_node_count" {
  default = 1
}

variable "machine_type" {
  default = "n1-standard-1"
}
