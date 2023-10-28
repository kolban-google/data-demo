#
#

# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/pubsub_topic
#
# Create a PubSub topic so that we can demonstrate that when we do a search, we an also
# see PubSub artifacts.
resource "google_pubsub_topic" "transactions" {
  name = "transactions"
} // google_pubsub_topic.transactions