defmodule MyApp.FilesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `MyApp.Files` context.
  """

  @doc """
  Generate a file.
  """
  def file_fixture(attrs \\ %{}) do
    {:ok, file} =
      attrs
      |> Enum.into(%{

      })
      |> MyApp.Files.create_file()

    file
  end
end
