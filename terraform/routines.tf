// Create a dataset within the project that will hold all the routines.
resource "google_bigquery_dataset" "routines" {
  dataset_id = "my_routines"
} // google_bigquery_dataset.routines


// Create a User Defined Function to show its capabilities.
//
// The function is called "revenue" and takes two inputs:
// * _unit_price: FLOAT64 - The price of a unit
// * _quantity: INT64 - The number of units purchased
// The return is a FLOAT64 that is the revenue (_unit_price * _quantity)
//
resource "google_bigquery_routine" "udf" {
  dataset_id      = google_bigquery_dataset.routines.dataset_id
  routine_id      = "revenue"
  routine_type    = "SCALAR_FUNCTION"
  language        = "SQL"
  description     = "Sample SQL UDF"
  definition_body = "_unit_price * _quantity"
  arguments {
    name      = "_unit_price"
    data_type = "{\"typeKind\" :  \"FLOAT64\"}"
  }
  arguments {
    name      = "_quantity"
    data_type = "{\"typeKind\" :  \"INT64\"}"
  }

  return_type = "{\"typeKind\" :  \"FLOAT64\"}"
} // google_bigquery_routine.udf
