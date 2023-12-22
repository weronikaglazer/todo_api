defmodule MyApp.ElasticsearchCluster do
  use Elasticsearch.Cluster, otp_app: :my_app
end
