defmodule MyApp.Repo.Migrations.RemoveAttachmentFromFiles do
  use Ecto.Migration

  def change do
    alter table(:files) do
      remove :attachment, :string, null: false
    end
  end
end
