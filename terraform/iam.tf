# Define a policy for secure authorization
data "google_iam_policy" "secure_authorized" {
  binding {
    role = "roles/datacatalog.categoryFineGrainedReader"
    members = [
      "group:${var.GROUP_HIGH_SECURITY}",
    ]
  }
} // google_iam_policy.secure_authorized


data "google_iam_policy" "secure_authorized_masked" {
  binding {
    role = "roles/bigquerydatapolicy.maskedReader"
    members = [
      "group:${var.GROUP_HIGH_SECURITY}",
    ]
  }
} // google_iam_policy.secure_authorized_masked


# Define a test user so that they are BQ data users
resource "google_project_iam_member" "project_a" {
  project = "${var.PROJECT_ID}"
  role    = "roles/bigquery.user"
  member  = "user:${var.USER_BQ_USER}"
} // google_project_iam_member.project_a


# Define a test user so that they are BQ data users
resource "google_project_iam_member" "project_b" {
  project = "${var.PROJECT_ID}"
  role    = "roles/bigquery.dataEditor"
  member  = "user:${var.USER_BQ_USER}"
} // google_project_iam_member.project_b