// Configure the Google Cloud provider
provider "google" {
  project = var.PROJECT_ID
  region = var.LOCATION
  user_project_override = true
  billing_project = var.PROJECT_ID
}

provider "google-beta" {
  project = var.PROJECT_ID
  region = var.LOCATION
  user_project_override = true
  billing_project = var.PROJECT_ID
}