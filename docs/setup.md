# Setup

In order to setup the demo, create a project and record the project ID.  Next, change into the terraform directory and perform the following:



1. Run `terraform init`

2. Edit `terraform.tfvars`

| Variable              | Value                                                                                                            |
| --------------------- | ---------------------------------------------------------------------------------------------------------------- |
| `PROJECT_ID`          | The project ID of the project                                                                                    |
| `GROUP_HIGH_SECURITY` | A group email id. The members of this group will be able to look at the customers table                          |
| `USER_BQ_USER`        | A user identity that will be granted BigQuery User role but should not be a member of the `GROUP_HIGH_SECURITY`. |

3. Run `terraform apply`


