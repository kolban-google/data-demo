# Create a VPC network.  

# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network
resource "google_compute_network" "vpc_network" {
  name                    = "vpc-network"
  auto_create_subnetworks = false
} // google_compute_network.vpc_network

# Create a Subnetwork for us-central1 with Private Google Access enabled.  We couldn't use
# auto mode creation as we needed to supply Private Google Access.
resource "google_compute_subnetwork" "vpc-network-us-central1" {
  name                     = "vpc-network-us-central1"
  ip_cidr_range            = "10.128.0.0/20"
  region                   = "us-central1"
  network                  = google_compute_network.vpc_network.id
  description              = "vpc-network-us-central1"
  private_ip_google_access = true
} // google_compute_subnetwork.vpc-network-us-central1
