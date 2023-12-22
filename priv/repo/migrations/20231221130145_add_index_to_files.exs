defmodule MyApp.Repo.Migrations.AddIndexToFiles do
  use Ecto.Migration

  def change do
    create unique_index(:files, [:name, :task_id])
  end
end
