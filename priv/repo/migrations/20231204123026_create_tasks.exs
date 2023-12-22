defmodule MyApp.Repo.Migrations.CreateTasks do
  use Ecto.Migration

  def change do
    create table(:tasks) do
      add :title, :string
      add :description, :string
      add :completed, :boolean, default: false
      add :user_id, references(:users, on_delete: :delete_all), null: false
    end
  end
end
