defmodule MyApp.ProfilesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `MyApp.Profiles` context.
  """

  @doc """
  Generate a profile.
  """
  def profile_fixture(attrs \\ %{}) do
    {:ok, profile} =
      attrs
      |> Enum.into(%{

      })
      |> MyApp.Profiles.create_profile()

    profile
  end
end
