defmodule MyApp.Repo.Migrations.CreateProfiles do
  use Ecto.Migration

  def change do
    create table(:profiles) do
      add :name, :string, null: false
      add :user_id, references(:users, on_delete: :delete_all, type: :bigint), null: false
    end

    create unique_index(:profiles, [:user_id])
    create unique_index(:profiles, [:name])
  end
end
