/*
resource "google_project_service" "compute" {
  service = "compute.googleapis.com"
}
resource "google_project_service" "dataplex" {
  service = "dataplex.googleapis.com"
}
resource "google_project_service" "dataproc" {
  service = "dataproc.googleapis.com"
  depends_on = [ google_project_service.compute ]
}
resource "google_project_service" "metastore" {
  service = "metastore.googleapis.com"
}
resource "google_project_service" "bigquery" {
  service = "bigquery.googleapis.com"
}
resource "google_project_service" "datacatalog" {
  service = "datacatalog.googleapis.com"
}
resource "google_project_service" "bigquerystorage" {
  service = "bigquerystorage.googleapis.com"
}
resource "google_project_service" "datalineage" {
  service = "datalineage.googleapis.com"
}
*/