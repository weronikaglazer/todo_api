defmodule MyAppWeb.TaskJSON do

  def index(%{tasks: tasks}) do
    %{tasks: Enum.map(tasks, &data/1)}
  end

  def index_search(%{tasks: tasks}) do
    %{tasks: Enum.map(tasks, &show_task_from_search/1)}
  end

  def data(task) do
    %{
      id: task.id,
      title: task.title,
      description: task.description,
      completed: task.completed,
      user_id: task.user_id
    }
  end

  def show_task_from_search(task) do
    %{
      elastic_search_id: task["id"],
      title: task["title"],
      description: task["description"],
      completed: task["completed"]
    }
  end

  def show_task(%{task: task, files: files}) do
    %{
        task: %{
        id: task.id,
        title: task.title,
        description: task.description || "",
        completed: task.completed || false,
        user_id: task.user_id,
        files: Enum.map(files, &MyAppWeb.FileJSON.data/1)
      }
    }
  end
end
