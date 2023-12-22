defmodule MyApp.Repo.Migrations.AddAttachmentToFiles do
  use Ecto.Migration

  def change do
    alter table(:files) do
      add :attachment, :string, null: false
    end
  end
end
