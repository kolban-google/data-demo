# Create the metastore for Dataplex Explore.  This can take up to 15-25 minutes to create.
# We currently need to use google-beta provider since the hive_metastore_config.endpoint_protocol is still beta.
#
resource "google_dataproc_metastore_service" "metastore-srv" {
  provider   = google-beta
  service_id = "metastore-srv"
  location   = var.LOCATION
  scaling_config {
    scaling_factor = "0.1"
  }
  hive_metastore_config {
    endpoint_protocol = "GRPC"
    version           = "3.1.2"
  }
  telemetry_config {
    log_format = "JSON"
  }
  /*
  database_type = "MYSQL" # Has to be MYSQL because of metadata_integration.data_catalog
  metadata_integration {
    data_catalog_config {
      enabled = true
    }
  }
  */
  database_type = "SPANNER"
  #network = google_compute_network.vpc_network.id
} // google_dataproc_metastore_service.metastore-srv
