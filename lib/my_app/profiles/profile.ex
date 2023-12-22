defmodule MyApp.Profiles.Profile do
  use Ecto.Schema
  import Ecto.Changeset

  schema "profiles" do
    field :name, :string
    belongs_to :user, MyApp.Users.User
  end

  def changeset(profile, attrs) do
    profile
    |> cast(attrs, [:user_id, :name])
    |> validate_required([:user_id, :name])
  end
end
