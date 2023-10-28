# Here we create:
#
# Data catalog entry group called thing_entry_group
# Data catalog entry called thing1
# Data catalog entry group called entry_group_ftp
# Data catalog entry called ftp_fileset
# Tag template called data_tag_template
#



# Create an entry group for a group of "things"
resource "google_data_catalog_entry_group" "thing_entry_group" {
  entry_group_id = "thing"
  description    = "The entry group for thing items"
} // google_data_catalog_entry_group.thing_entry_group


# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/data_catalog_entry
# Create an entry for an instance of a thing.
resource "google_data_catalog_entry" "thing1" {
  entry_group           = google_data_catalog_entry_group.thing_entry_group.name
  entry_id              = "thing1"
  user_specified_type   = "thing_entry"
  user_specified_system = "thing_system"
  linked_resource       = "//things/thing"
  description           = "Description for thing1"
  display_name          = "thing1"
} // google_data_catalog_entry.thing1


resource "google_data_catalog_entry_group" "entry_group_ftp" {
  entry_group_id = "entry_group_ftp"
  description    = "The entry group for entry_group_ftp items"
} // google_data_catalog_entry_group.entry_group_ftp


resource "google_data_catalog_entry" "ftp_fileset" {
  entry_group = google_data_catalog_entry_group.entry_group_ftp.name
  entry_id    = "ftp_fileset"
  type        = "FILESET"
  gcs_fileset_spec {
    file_patterns = ["gs://${local.BUCKET_FTP}/*"]
  }
} // google_data_catalog_entry.ftp_fileset


#
# Create the tag template called "data_tag_template"
#
resource "google_data_catalog_tag_template" "data_tag_template" {
  tag_template_id = "data_tag_template"
  display_name    = "data_tag_template"
  force_delete    = true
  fields {
    field_id     = "owner"
    display_name = "Owner"
    description  = "The owner of this asset"
    type {
      primitive_type = "STRING"
    }
    is_required = true
  }

  fields {
    field_id     = "department"
    display_name = "Department"
    description  = "The department responsible for this asset"
    type {
      enum_type {
        allowed_values {
          display_name = "Finance"
        }
        allowed_values {
          display_name = "Sales"
        }
        allowed_values {
          display_name = "Human Resources"
        }
        allowed_values {
          display_name = "IT"
        }
      }
    }
  }
} // google_data_catalog_tag_template.data_tag_template


# Attach an instance of the data_tag_template tag to the customers table
#
# Puzzle: When we wish to attach a tag template to a data catalog entry, we need the
# if of that entry.  However, if the entry was implicitly created because of auto discovery
# how can we determine the value of the entry id as it is automatically generated?
# For example, imagine we create a BigQuery table called "customers", how can we
# attach a tag to this table as the entry id for the table was generated?
#
/*
resource "google_data_catalog_tag" "customers_tag" {
  parent   = google_data_catalog_entry.entry.id
  template = google_data_catalog_tag_template.data_tag_template.id

  fields {
    field_name   = "owner"
    string_value = "kolban@google.com"
  }

  fields {
    field_name   = "department"
    string_value = "Sales"
  }
} // google_data_catalog_tag.customers_tag
*/
