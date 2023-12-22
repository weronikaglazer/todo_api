defmodule MyApp.Repo.Migrations.RemoveIndexFromFiles do
  use Ecto.Migration

  def change do
    drop unique_index(:files, :name)
  end
end
