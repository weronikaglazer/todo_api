defimpl Elasticsearch.Document, for: MyApp.Task do
  def id(task), do: task.id
  def routing(_), do: false
  def encode(task) do
    %{
      id: task.id,
      title: task.title,
      description: task.description,
      completed: task.completed,
      user_id: task.user_id
    }
  end
end
