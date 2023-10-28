# Items created:
# A dataplex lake
# A dataplex zone associated with the lake
#
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/dataplex_lake


# Create the dataplex lake
# The creation of the lake can take a few minutes
resource "google_dataplex_lake" "lake" {
  name         = var.LAKE
  description  = "Lake for ${var.LAKE}"
  display_name = "Lake for ${var.LAKE}"
  location     = var.LOCATION
  metastore {
    service = google_dataproc_metastore_service.metastore-srv.id
  }
} // google_dataplex_lake.lake


resource "google_dataplex_zone" "zone" {
  discovery_spec {
    enabled = true
    schedule = "0 0 * * *"
  }
  lake     = google_dataplex_lake.lake.name
  location = "us-central1"
  name     = var.ZONE
  resource_spec {
    location_type = "SINGLE_REGION"
  }
  type         = "RAW"
  description  = "Zone for ${var.ZONE}"
  display_name = "Zone for ${var.ZONE}"
} // google_dataplex_zone.zone


resource "google_dataplex_asset" "customers-asset" {
  name          = "customers-asset"
  location      = var.LOCATION
  lake          = google_dataplex_lake.lake.name
  dataplex_zone = google_dataplex_zone.zone.name

  discovery_spec {
    enabled = google_dataplex_zone.zone.discovery_spec[0].enabled
    schedule = google_dataplex_zone.zone.discovery_spec[0].schedule
  }
/*
  discovery_spec {
    enabled  = true
    schedule = "0 0 * * *"
  }
  */

  resource_spec {
    name = google_bigquery_dataset.customers.id
    type = "BIGQUERY_DATASET"
  }
} // google_dataplex_asset.customers-asset


resource "google_dataplex_asset" "sales-asset" {
  name          = "sales-asset"
  location      = var.LOCATION
  lake          = google_dataplex_lake.lake.name
  dataplex_zone = google_dataplex_zone.zone.name

  discovery_spec {
    enabled  = true
    schedule = "0 0 * * *"
  }

  resource_spec {
    name = google_bigquery_dataset.sales.id
    type = "BIGQUERY_DATASET"
  }
} // google_dataplex_asset.sales-asset


resource "google_dataplex_asset" "stock-asset" {
  name          = "stock-asset"
  location      = var.LOCATION
  lake          = google_dataplex_lake.lake.name
  dataplex_zone = google_dataplex_zone.zone.name

  discovery_spec {
    enabled  = true
    schedule = "0 0 * * *"
  }

  resource_spec {
    name = "projects/${google_storage_bucket.data.project}/buckets/${google_storage_bucket.data.name}"
    type = "STORAGE_BUCKET"
  }
} // google_dataplex_asset.stock-asset


# Create a profile scan on the sales table.   Run the scan once done.
resource "google_dataplex_datascan" "profile-sales" {
  location     = var.LOCATION
  data_scan_id = "profile-sales"

  data {
    resource = "//bigquery.googleapis.com/${google_bigquery_table.sales.id}"
  }

  execution_spec {
    trigger {
      on_demand {}
    }
  }

  data_profile_spec {
    post_scan_actions {
      bigquery_export {
        results_table = "//bigquery.googleapis.com/${google_bigquery_dataset.reports.id}/tables/profile_export"
      }
    }
  }

  provisioner "local-exec" {
    command = "gcloud dataplex datascans run ${self.name} --location=${self.location} --project=${self.project}"
  }
} // google_dataplex_datascan.profile-sales


# Create a data quality scan on the sales table
resource "google_dataplex_datascan" "quality-sales" {
  location     = var.LOCATION
  data_scan_id = "quality-sales"

  data {
    resource = "//bigquery.googleapis.com/${google_bigquery_table.sales.id}"
  }

  execution_spec {
    trigger {
      on_demand {}
    }
  }

  data_quality_spec {
    rules {
      column      = "item"
      dimension   = "VALIDITY"
      name        = "item-check"
      ignore_null = true
      set_expectation {
        values = ["Red Widget", "Green Widget", "Blue Widget"]
      }
      threshold   = 1
      description = "Check that the items are known"

    }
    post_scan_actions {
      bigquery_export {
        results_table = "//bigquery.googleapis.com/${google_bigquery_dataset.reports.id}/tables/quality_export"
      }
    }
  }
} // google_dataplex_datascan.quality-sales
