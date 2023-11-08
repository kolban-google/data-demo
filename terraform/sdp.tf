/*
resource "google_data_loss_prevention_job_trigger" "customers" {
  parent = "projects/${var.PROJECT_ID}"
  inspect_job {
    storage_config {
      big_query_options {
        table_reference {
          project_id = google_bigquery_table.customers.project
          dataset_id = google_bigquery_table.customers.dataset_id
          table_id   = google_bigquery_table.customers.table_id
        }
        rows_limit    = 1000
        sample_method = "RANDOM_START"
      }
    }
  }
}
*/
