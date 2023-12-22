defmodule MyApp.Repo.Migrations.RemoveIndexFromUsers do
  use Ecto.Migration

  def change do
    drop unique_index(:users, [:mobile, :email])
  end
end
