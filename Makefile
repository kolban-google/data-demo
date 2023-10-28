#
# Review and change the following variables for your environment
#
PROJECT_ID=kolban-dataplex-demo-10-06-02
LOCATION=us-central1
LAKE=my-business-4
ZONE=operations
BUCKET=$(PROJECT_ID)-data
BUCKET_FTP=$(PROJECT_ID)-ftp

SALES_DATASET=sales_ds
CUSTOMERS_DATASET=customers_ds
ENTRY_GROUP_FTP=entry_group_ftp
THING_ENTRY_GROUP=thing

all:
	@echo "Dataplex demo"
	@echo
	@echo "Project:  $(PROJECT_ID)"
	@echo "Lake:     $(LAKE)"
	@echo "Zone:     $(ZONE)"
	@echo "Bucket:   $(BUCKET)"
	@echo "Location: $(LOCATION)"
	@echo
	@echo "create-dataplex-resources - Create the Dataplex resources in the project"
	@echo "delete-dataplex-resources - Delete the Dataplex resources from the project"
	@echo "enable-services           - Enable the services needed for the demo"
	@echo "create-bq-resources       - Create the BQ resources in the project"
	@echo "delete-bq-resources       - Delete the BQ resources from the project"
	@echo "create-gcs-resources      - Create the GCS resources in the project"
	@echo "create-project            - Create the Project"	

create-all: create-project enable-services create-bq-resources create-gcs-resources create-dataplex-resources

create-project:
	gcloud projects create $(PROJECT_ID)

enable-services:
	gcloud services enable \
		compute.googleapis.com \
		dataplex.googleapis.com \
		dataproc.googleapis.com \
		metastore.googleapis.com \
		bigquery.googleapis.com \
		datacatalog.googleapis.com \
		bigquerystorage.googleapis.com \
		datalineage.googleapis.com \
		pubsub.googleapis.com \
		--project=$(PROJECT_ID)

create-bq-resources:
	-bq --location=$(LOCATION) --project_id=$(PROJECT_ID) mk --dataset $(CUSTOMERS_DATASET)
	-bq --location=$(LOCATION) --project_id=$(PROJECT_ID) mk --dataset $(SALES_DATASET)
	-bq --location=us-central1 \
		--project_id=$(PROJECT_ID) load \
  		--autodetect \
  		--source_format=CSV \
		customers_ds.customers ./data/customers.csv
	-bq --location=us-central1 \
		--project_id=$(PROJECT_ID) load \
  		--autodetect \
  		--source_format=CSV \
		sales_ds.sales ./data/sales.csv
	-bq --location=$(LOCATION) --project_id=$(PROJECT_ID) mk \
		--use_legacy_sql=false \
		--view \
		"SELECT * EXCEPT(email) FROM $(CUSTOMERS_DATASET).customers" \
		$(CUSTOMERS_DATASET).customers_no_email_v		

delete-bq-resources:
	-bq --location=$(LOCATION) --project_id=$(PROJECT_ID) rm --force=true --dataset=true --recursive=true $(CUSTOMERS_DATASET)
	-bq --location=$(LOCATION) --project_id=$(PROJECT_ID) rm --force=true --dataset=true --recursive=true $(SALES_DATASET)

create-gcs-resources:
	-gcloud storage buckets create gs://$(BUCKET) --location=$(LOCATION) --project=$(PROJECT_ID)
	-gcloud storage cp ./data/stock.parquet gs://$(BUCKET)
	-gcloud storage buckets create gs://$(BUCKET_FTP) --location=$(LOCATION) --project=$(PROJECT_ID)
	-gcloud storage cp ./data/2023-10-08.json gs://$(BUCKET_FTP)

# Delete the following Dataplex assets
# Asset: customers-asset
# Asset: sales-asset
# Asset: stock-asset
# Zone: $(ZONE)
# Lake: $(LAKE)
delete-dataplex-resources:
	@echo "# Deleting asset: customers-asset"
	-gcloud dataplex assets delete customers-asset --lake=$(LAKE) --zone=$(ZONE) --location=$(LOCATION) --project=$(PROJECT_ID) --quiet
	@echo "# Deleting asset: sales-asset"
	-gcloud dataplex assets delete sales-asset --lake=$(LAKE) --zone=$(ZONE) --location=$(LOCATION) --project=$(PROJECT_ID) --quiet
	@echo "# Deleting asset: stock-asset"
	-gcloud dataplex assets delete stock-asset --lake=$(LAKE) --zone=$(ZONE) --location=$(LOCATION) --project=$(PROJECT_ID) --quiet
	@echo "# Deleting zone: $(ZONE)"
	-gcloud dataplex zones delete $(ZONE) --lake=$(LAKE) --location=$(LOCATION) --project=$(PROJECT_ID) --quiet
	@echo "# Deleting lake: $(LAKE)"
	-gcloud dataplex lakes delete $(LAKE) --location=$(LOCATION) --project=$(PROJECT_ID) --quiet
#
# Create the following Dataplex assets
#
# Lake: $(LAKE)
# Zone: $(ZONE)
# Asset: customers-asset
# Asset: sales-asset
# Asset: stock-asset
create-dataplex-resources:
	@date
	@echo "# Creating lake: $(LAKE)"
	-gcloud dataplex lakes create $(LAKE) \
  		--location=$(LOCATION) \
  		--description="My demo lake description" \
  		--display-name="Lake for $(LAKE)" \
		--project=$(PROJECT_ID)
	@echo "# Creating zone: $(ZONE)"
	-gcloud dataplex zones create $(ZONE) \
		--lake=$(LAKE) \
		--location=$(LOCATION) \
 		--resource-location-type=SINGLE_REGION \
 		--type=RAW \
		--description="Operations Zone" \
		--display-name="Operations Zone" \
		--project=$(PROJECT_ID)
	@echo "# Attaching asset: customers-asset to zone: $(ZONE)"
	-gcloud dataplex assets create customers-asset \
  	--lake=$(LAKE) \
		--zone=$(ZONE) \
		--location=$(LOCATION) \
		--resource-type=BIGQUERY_DATASET \
		--resource-name=projects/$(PROJECT_ID)/datasets/$(CUSTOMERS_DATASET) \
		--resource-read-access-mode=DIRECT \
		--discovery-enabled \
		--project=$(PROJECT_ID)
	@echo "# Attaching asset: sales-asset to zone: $(ZONE)"
	-gcloud dataplex assets create sales-asset \
  	--lake=$(LAKE) \
		--zone=$(ZONE) \
		--location=$(LOCATION) \
		--resource-type=BIGQUERY_DATASET \
		--resource-name=projects/$(PROJECT_ID)/datasets/$(SALES_DATASET) \
		--resource-read-access-mode=DIRECT \
		--discovery-enabled \
		--project=$(PROJECT_ID)		
	@echo "# Attaching asset: stock-asset to zone: $(ZONE)"		
	-gcloud dataplex assets create stock-asset \
  	--lake=$(LAKE) \
		--zone=$(ZONE) \
		--location=$(LOCATION) \
		--resource-type=STORAGE_BUCKET \
		--resource-name=projects/$(PROJECT_ID)/buckets/$(BUCKET) \
		--resource-read-access-mode=DIRECT \
		--discovery-enabled \
		--project=$(PROJECT_ID)
	@date

#
# Create data catalog entries
#
create-data-catalog:
	-gcloud data-catalog entry-groups create $(THING_ENTRY_GROUP) \
		--location=$(LOCATION) \
		--project=$(PROJECT_ID)
	-gcloud data-catalog entries create thing1 \
		--entry-group=$(THING_ENTRY_GROUP) \
		--display-name="thing1" \
		--description="Description for thing1" \
		--user-specified-type=THING_ENTRY \
		--user-specified-system=THING_SYSTEM \
		--linked-resource="my-linked-resource-data" \
		--location=$(LOCATION) \
		--project=$(PROJECT_ID)
	-gcloud data-catalog entry-groups create $(ENTRY_GROUP_FTP) \
		--location=$(LOCATION) \
		--project=$(PROJECT_ID)
	-gcloud data-catalog entries create ftp_fileset \
	  --entry-group=$(ENTRY_GROUP_FTP) \
	  --type=FILESET \
		--gcs-file-patterns="gs://$(BUCKET_FTP)/*" \
		--location=$(LOCATION) \
		--project=$(PROJECT_ID)
	# Create a tag-template called data_tag_template
	-gcloud data-catalog tag-templates create data_tag_template \
		--location=$(LOCATION) \
		--project=$(PROJECT_ID) \
		--display-name="data_tag_template" \
		--field=id=owner,display-name="Owner",type="string",required=TRUE \
		--field=id=department,display-name="Department",type="enum(Finance|Sales|Human Resources|IT)"
	-gcloud data-catalog tags create \
		--tag-file=data/tag1.json \
		--entry=$(shell gcloud data-catalog entries lookup 'bigquery.table.`$(PROJECT_ID)`.$(CUSTOMERS_DATASET).customers' \
			--project=$(PROJECT_ID) \
			--format="value(name)") \
		--tag-template=data_tag_template \
		--location=$(LOCATION) \
		--project=$(PROJECT_ID)		

delete-data-catalog:
	-gcloud data-catalog tag-templates delete data_tag_template \
		--force \
		--location=$(LOCATION) \
		--project=$(PROJECT_ID) \
		--quiet
	-gcloud data-catalog entries delete thing1 \
		--entry-group=$(THING_ENTRY_GROUP) \
		--location=$(LOCATION) \
		--project=$(PROJECT_ID) \
		--quiet
	gcloud data-catalog entry-groups delete $(THING_ENTRY_GROUP) \
		--location=$(LOCATION) \
		--project=$(PROJECT_ID) \
		--quiet
	-gcloud data-catalog entries delete ftp_fileset \
		--entry-group=$(ENTRY_GROUP_FTP) \
		--location=$(LOCATION) \
		--project=$(PROJECT_ID) \
		--quiet		
	gcloud data-catalog entry-groups delete $(ENTRY_GROUP_FTP) \
		--location=$(LOCATION) \
		--project=$(PROJECT_ID) \
		--quiet		

#
# Create and run the Dataplex profile scans
#
create-dataplex-profile-scans:
	@echo "Creating the profile scan"
	-gcloud dataplex datascans create data-profile profile-scan-sales \
		--location=$(LOCATION) \
		--project=$(PROJECT_ID) \
		--data-source-resource="//bigquery.googleapis.com/projects/$(PROJECT_ID)/datasets/$(SALES_DATASET)/tables/sales" \
		--on-demand=true
	@echo "Running the profile scan"
	gcloud dataplex datascans run profile-scan-sales \
		--location=$(LOCATION) \
		--project=$(PROJECT_ID) \

describe-asset:
	gcloud dataplex assets describe customers-asset \
		--lake=$(LAKE) \
		--zone=$(ZONE) \
		--location=$(LOCATION) \
		--project=$(PROJECT_ID) \
		--format=json

test:
	gcloud data-catalog entries create thing1 \
		--entry-group=$(THING_ENTRY_GROUP) \
		--user-specified-type=THING_ENTRY \
		--user-specified-system=THING_SYSTEM \
		--location=$(LOCATION) \
		--project=$(PROJECT_ID)

test2:
	gcloud data-catalog entries describe thing1 \
		--entry-group=$(THING_ENTRY_GROUP) \
		--location=$(LOCATION) \
		--project=$(PROJECT_ID) \
		--format=json

test3:
	gcloud data-catalog tag-templates describe data_tag_template \
		--location=$(LOCATION) \
		--project=$(PROJECT_ID) \
		--format=json

test4:
	gcloud data-catalog tag-templates create data_tag_template \
		--location=$(LOCATION) \
		--project=$(PROJECT_ID) \
		--display-name="data_tag_template" \
		--field=id=owner,display-name="Owner",type="string",required=TRUE \
		--field=id=department,display-name="Department",type="enum(Finance|Sales|Human Resources|IT)"

test5:
	gcloud data-catalog tags list \
		--entry="cHJvamVjdHMva29sYmFuLWRhdGFwbGV4LWRlbW8tMTAtMDYtMDIvZGF0YXNldHMvY3VzdG9tZXJzX2RzL3RhYmxlcy9jdXN0b21lcnM" \
		--entry-group="@bigquery" \
		--location=$(LOCATION) \
		--project=$(PROJECT_ID)

test6:
	gcloud data-catalog entries lookup //bigquery.googleapis.com/projects/kolban-dataplex-demo-10-06-02/datasets/customers_ds/tables/customers \
		--project=$(PROJECT_ID) \
		--format=json

test6_1:
	gcloud data-catalog entries lookup 'bigquery.table.`kolban-dataplex-demo-10-06-02`.customers_ds.customers' \
		--project=$(PROJECT_ID) \
		--format=json

test7:
	gcloud data-catalog tags create \
		--tag-file=data/tag1.json \
		--entry=$(shell gcloud data-catalog entries lookup 'bigquery.table.`kolban-dataplex-demo-10-06-02`.customers_ds.customers' \
		--project=$(PROJECT_ID) \
		--format="value(name)") \
		--tag-template=data_tag_template \
		--location=$(LOCATION) \
		--project=$(PROJECT_ID)

test8:
	gcloud dataplex lakes list \
		--location=$(LOCATION) \
		--project=$(PROJECT_ID)

test9:
	gcloud metastore services list \
		--location=$(LOCATION) \
		--project=$(PROJECT_ID) \
		--format=json

test10:
	gcloud dataplex datascans list \
		--location=$(LOCATION) \
		--project=$(PROJECT_ID) \
		--format=json

test11:
	gcloud dataplex datascans describe sales-quality-scan \
		--view=full \
		--location=$(LOCATION) \
		--project=$(PROJECT_ID) \
		--format=json

test12:
	gcloud dataflow jobs run job2 \
		--gcs-location gs://dataflow-templates/latest/Word_Count \
		--region=us-central1 \
		--project=$(PROJECT_ID) \
		--disable-public-ips \
		--subnetwork=regions/us-central1/subnetworks/vpc-network-us-central1 \
		--parameters \
		inputFile=gs://dataflow-samples/shakespeare/kinglear.txt,output=gs://kolban-dataplex-demo-10-06-02-tmp/output/my_output

test13:
	gcloud dataplex tasks list --lake=my-business-4 \
		--location=$(LOCATION) \
		--project=$(PROJECT_ID)	
