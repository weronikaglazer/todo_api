defmodule MyApp.Repo.Migrations.CreateFiles do
  use Ecto.Migration

  def change do
    create table(:files) do
      add :name, :string, null: false
      add :path, :string, null: false
      add :task_id, references(:tasks, on_delete: :delete_all), null: false
    end

    create unique_index(:files, :name)
  end
end
