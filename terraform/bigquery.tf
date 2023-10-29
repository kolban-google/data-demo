#
# Create the CUSTOMERS_DATASET dataset
resource "google_bigquery_dataset" "customers" {
  dataset_id = var.CUSTOMERS_DATASET
} // google_bigquery_dataset.customers


# Create the SALES_DATASET dataset
resource "google_bigquery_dataset" "sales" {
  dataset_id = var.SALES_DATASET
} // google_bigquery_dataset.sales


# Create the Reports dataset
resource "google_bigquery_dataset" "reports" {
  dataset_id = "_reports"
} // google_bigquery_dataset.reports


# Create the sales table
resource "google_bigquery_table" "sales" {
  dataset_id = google_bigquery_dataset.sales.dataset_id
  table_id   = "sales"
} // google_bigquery_table.sales


# Create the customers table
# This depends on a policy tag.
resource "google_bigquery_table" "customers" {
  dataset_id = google_bigquery_dataset.customers.dataset_id
  table_id   = "customers"
  schema     = <<EOF
[
  {
    "name": "cust_id",
    "type": "INTEGER",
    "mode": "NULLABLE",
    "description": "Customer Id"
  },
  {
    "name": "name",
    "type": "STRING",
    "mode": "NULLABLE",
    "description": "Customer name"
  },
  {
    "name": "address",
    "type": "STRING",
    "mode": "NULLABLE",
    "description": "Customer name"
  },
  {
    "name": "email",
    "type": "STRING",
    "mode": "NULLABLE",
    "description": "Customer email",
    "policyTags":{
      "names": [
        "${google_data_catalog_policy_tag.high.id}"
      ]
    }
  },
  {
    "name": "ccard",
    "type": "STRING",
    "mode": "NULLABLE",
    "description": "Credit card nubmer",
    "policyTags":{
      "names": [
        "${google_data_catalog_policy_tag.ccard.id}"
      ]
    }
  }
]
EOF
  depends_on = [google_data_catalog_policy_tag.high]
} // google_bigquery_table.customers


resource "google_storage_bucket" "tmp" {
  name                        = local.BUCKET_TMP
  location                    = var.LOCATION
  uniform_bucket_level_access = true
} // google_storage_bucket.tmp


resource "google_storage_bucket_object" "sales_data" {
  name         = "sales.csv"
  source       = "../data/sales.csv"
  content_type = "text/plain"
  bucket       = google_storage_bucket.tmp.name
} // google_storage_bucket_object.sales_data

# To reload the bucket with the local data, run "terraform taint google_storage_bucket_object.customers_data"
resource "google_storage_bucket_object" "customers_data" {
  name         = "customers.csv"
  source       = "../data/customers.csv"
  content_type = "text/plain"
  bucket       = google_storage_bucket.tmp.name
} // google_storage_bucket_object.customers_data


resource "random_uuid" "sales_load" {
} // random_uuid.sales_load


# Load the sales table from the data in the bucket.
# The data is loaded into the bucket by the resource: google_storage_bucket_object.sales_data
resource "google_bigquery_job" "sales_load" {
  job_id = "sales_load_${random_uuid.sales_load.id}"

  load {
    source_uris = [
      "gs://${google_storage_bucket_object.sales_data.bucket}/${google_storage_bucket_object.sales_data.name}"
    ]

    destination_table {
      project_id = google_bigquery_table.sales.project
      dataset_id = google_bigquery_table.sales.dataset_id
      table_id   = google_bigquery_table.sales.table_id
    }

    skip_leading_rows = 1
    #autodetect        = true
    write_disposition = "WRITE_TRUNCATE"
  }
} // google_bigquery_job.sales_load

# To force a reload of the customers data, run: "terraform taint random_uuid.customers_load"
resource "random_uuid" "customers_load" {
} // random_uuid.customers_load


resource "google_bigquery_job" "customers_load" {
  job_id = "customers_load_${random_uuid.customers_load.id}"
  load {
    source_uris = [
      "gs://${google_storage_bucket_object.customers_data.bucket}/${google_storage_bucket_object.customers_data.name}"
    ]

    destination_table {
      project_id = google_bigquery_table.customers.project
      dataset_id = google_bigquery_table.customers.dataset_id
      table_id   = google_bigquery_table.customers.table_id
    }

    skip_leading_rows = 1
    #autodetect        = true
    write_disposition = "WRITE_TRUNCATE"
  }
  depends_on = [ google_bigquery_table.customers, google_storage_bucket_object.customers_data ]
} // google_bigquery_job.customers_load
