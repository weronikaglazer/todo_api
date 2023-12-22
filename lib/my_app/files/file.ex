defmodule MyApp.Files.File do
  use Ecto.Schema
  import Ecto.Changeset

  schema "files" do
    field :name, :string
    field :path, :string
    belongs_to :task, MyApp.Tasks.Task
  end

  @doc false
  def changeset(file, attrs) do
    file
    |> cast(attrs, [:name, :path, :task_id])
    |> validate_required([:name, :path, :task_id])
    |> unique_constraint([:name, :task_id])
  end
end
