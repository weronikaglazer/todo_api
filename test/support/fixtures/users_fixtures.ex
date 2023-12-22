defmodule MyApp.UsersFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `MyApp.Users` context.
  """

  @doc """
  Generate a user.
  """
  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(%{
        email: "test@test.com",
        info: %{},
        mobile: "999888222",
        password_hash: Bcrypt.hash_pwd_salt("password123")
      })
      |> MyApp.Users.create_user()

    user
  end
end
