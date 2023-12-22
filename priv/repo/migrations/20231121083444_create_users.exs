defmodule MyApp.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :mobile, :string, null: false, unique: true
      add :email, :string, null: false, unique: true
      add :password_hash, :string, null: false
      add :info, :map, default: %{}
      add :task_ids, {:array, :integer}, default: []
      timestamps()
    end

    create unique_index(:users, [:mobile, :email])
    create unique_index(:users, [:mobile])
    create unique_index(:users, [:email])
  end
end
