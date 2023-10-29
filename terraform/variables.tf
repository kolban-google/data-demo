variable "PROJECT_ID" {
  type = string
}

variable "CUSTOMERS_DATASET" {
  type = string
}

variable "SALES_DATASET" {
  type = string
}

variable "LAKE" {
  type = string
}

variable "ZONE" {
  type = string
}

variable "LOCATION" {
  type = string
}

variable "GROUP_HIGH_SECURITY" {
  type = string
}

# The identity of an unprivilleged BQ user.
variable "USER_BQ_USER" {
  type = string
}