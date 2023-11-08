# Create Policy Tags taxonomy


resource "google_data_catalog_taxonomy" "my_taxonomy" {
  display_name           = "my_taxonomy"
  description            = "A collection of policy tags"
  activated_policy_types = ["FINE_GRAINED_ACCESS_CONTROL"]
  region                 = "us"
} // google_data_catalog_taxonomy.my_taxonomy


resource "google_data_catalog_policy_tag" "low" {
  taxonomy     = google_data_catalog_taxonomy.my_taxonomy.id
  display_name = "Low security"
  description  = "A policy tag normally associated with low security items"
} // google_data_catalog_policy_tag.low


resource "google_data_catalog_policy_tag" "high" {
  taxonomy     = google_data_catalog_taxonomy.my_taxonomy.id
  display_name = "High security"
  description  = "A policy tag normally associated with high security items"
} // google_data_catalog_policy_tag.high


resource "google_data_catalog_policy_tag" "ccard" {
  taxonomy     = google_data_catalog_taxonomy.my_taxonomy.id
  display_name = "Credit Cards"
  description  = "A policy tag associated with credit cards"
} // google_data_catalog_policy_tag.ccard


# Set the IAM permissions on the high policy
resource "google_data_catalog_policy_tag_iam_policy" "high" {
  policy_tag  = google_data_catalog_policy_tag.high.name
  policy_data = data.google_iam_policy.secure_authorized.policy_data
} // google_data_catalog_policy_tag_iam_policy.high


resource "google_bigquery_datapolicy_data_policy" "data_policy" {
  location         = "us"
  data_policy_id   = "ccard_masking"
  policy_tag       = google_data_catalog_policy_tag.ccard.name
  data_policy_type = "DATA_MASKING_POLICY"
  data_masking_policy {
    predefined_expression = "LAST_FOUR_CHARACTERS"
  }
} // google_bigquery_datapolicy_data_policy.data_policy


resource "google_bigquery_datapolicy_data_policy_iam_policy" "ccard" {
    policy_data = data.google_iam_policy.secure_authorized_masked.policy_data
    data_policy_id = google_bigquery_datapolicy_data_policy.data_policy.id
} // google_bigquery_datapolicy_data_policy_iam_policy.ccard


