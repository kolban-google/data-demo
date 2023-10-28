#
#
resource "google_storage_bucket" "data" {
  name                        = local.BUCKET
  location                    = var.LOCATION
  uniform_bucket_level_access = true
} // google_storage_bucket.data


resource "google_storage_bucket" "ftp" {
  name                        = local.BUCKET_FTP
  location                    = var.LOCATION
  uniform_bucket_level_access = true
} // google_storage_bucket.ftp


resource "google_storage_bucket_object" "stock_parquet" {
  name         = "stock.parquet"
  source       = "../data/stock.parquet"
  content_type = "text/plain"
  bucket       = google_storage_bucket.data.name
} // google_storage_bucket_object.stock_parquet


resource "google_storage_bucket_object" "ftp_data" {
  name         = "2023-10-08.json"
  source       = "../data/2023-10-08.json"
  content_type = "application/json"
  bucket       = google_storage_bucket.ftp.name
} // google_storage_bucket_object.data
