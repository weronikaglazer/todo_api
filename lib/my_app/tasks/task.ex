defmodule MyApp.Tasks.Task do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :id, autogenerate: false}
  schema "tasks" do
    field :title, :string
    field :description, :string, default: ""
    field :completed, :boolean, default: false
    belongs_to :user, MyApp.Users.User
    has_many :files, MyApp.Files.File
  end

  @doc false
  def changeset(task, attrs) do
    task
    |> cast(attrs, [:id, :title, :description, :completed, :user_id])
    |> validate_required([:id, :title, :user_id])
    |> validate_length(:title, min: 10, message: "must contain at least 10 characters")
    |> cast_assoc(:files)
  end
end
