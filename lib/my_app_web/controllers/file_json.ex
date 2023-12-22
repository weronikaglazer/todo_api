defmodule MyAppWeb.FileJSON do

  def index(%{files: files}) do
    %{files: Enum.map(files, &data/1)}
  end

  def data(file) do
    %{
      id: file.id,
      name: file.name,
      path: file.path,
      task_id: file.task_id
    }
  end

  def show_file(%{file: file}) do
    %{
        file: %{
          id: file.id,
          name: file.name,
          path: file.path,
          task_id: file.task_id
      }
    }
  end
end
