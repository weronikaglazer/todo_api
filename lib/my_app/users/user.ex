defmodule MyApp.Users.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :mobile, :string
    field :email, :string
    field :password_hash, :string
    field :info, :map, default: %{}
    field :task_ids, {:array, :integer}, default: []
    has_one :profile, MyApp.Profiles.Profile
    has_many :tasks, MyApp.Tasks.Task

    timestamps()
  end

  defp all_fields do
    __MODULE__.__schema__(:fields)
  end

  def changeset(user, attrs \\ %{}) do
    user
    |> cast(attrs, all_fields())
    |> validate_required([:mobile, :email, :password_hash])
    |> validate_format(:mobile, ~r/[0-9]{9}/, message: "must have 9 digits and no spaces")
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/, message: "must have the @ sign and no spaces")
    |> unique_constraint(:mobile)
    |> unique_constraint(:email)
    |> put_password_hash()
  end

  defp put_password_hash(%Ecto.Changeset{valid?: true, changes: %{password_hash: password_hash}} = changeset) do
    change(changeset, password_hash: Bcrypt.hash_pwd_salt(password_hash))
  end

  defp put_password_hash(changeset), do: changeset
end
