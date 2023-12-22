defmodule MyApp.ElasticsearchService do
  alias MyApp.{ElasticsearchCluster}
  alias Elasticsearch

  def put_task(task) do
    case Elasticsearch.put_document(ElasticsearchCluster, task, "tasks") do
      {:ok, data} -> {:ok, data}
      {:error, reason} -> {:error, reason}
    end
  end

  def update_task(previous_task, new_task_params) do
    new_task = %MyApp.Task{
      id: previous_task["id"],
      title: new_task_params["title"] || previous_task["title"],
      description: new_task_params["description"] || previous_task["description"],
      completed: new_task_params["completed"] || previous_task["completed"],
      user_id: previous_task["user_id"]
    }

    with {:ok, _data} <- Elasticsearch.put_document(ElasticsearchCluster, new_task, "tasks") do
          :ok
    end
  end

  def search(search_query) do
    case Elasticsearch.post(
      ElasticsearchCluster,
      "/tasks/_doc/_search?pretty",
      search_query) do

        {:ok, data} ->
          case Enum.empty?(data["hits"]["hits"]) do
            true ->
              {:ok, []}
            false ->
              tasks = Enum.map(data["hits"]["hits"], &(&1["_source"]))
              {:ok, tasks}
          end

        {:error, _message} ->
          {:error, "Failed to perform search"}
    end
  end

  def delete_task(task_params) do
    task_to_delete = %MyApp.Task{
      id: task_params["id"],
      title: task_params["title"],
      description: task_params["description"],
      completed: task_params["completed"],
      user_id: task_params["user_id"]
    }

    with {:ok, _deleted_task} <- Elasticsearch.delete_document(ElasticsearchCluster, task_to_delete, "tasks") do
      :ok
    end
  end

  def delete_user_tasks(user_id) do
    case search(%{"query" => %{"match" => %{"user_id" => user_id}}}) do
      {:ok, []} -> :ok
      {:ok, tasks} ->
        with :ok <- Enum.each(tasks, fn task -> delete_task(task) end) do
          :ok
        end
    end
  end
end
