defmodule MyApp.Repo.Migrations.AlterTasksTable do
  use Ecto.Migration

  def change do
    alter table(:tasks) do
      modify :title, :string, null: false
      modify :description, :string, null: false, default: ""
      modify :completed, :boolean, null: false, default: false
    end
  end
end
