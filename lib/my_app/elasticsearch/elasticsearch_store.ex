defmodule MyApp.ElasticsearchStore do
  @behaviour Elasticsearch.Store

  @impl true
  def stream(_schema) do
    []
  end

  @impl true
  def transaction(fun) do
    fun.()
  end
end
