defmodule MyAppWeb.ProfileJSON do
  alias MyApp.Profiles.Profile

  @doc """
  Renders a list of profiles.
  """
  def index(%{profiles: profiles}) do
    %{data: for(profile <- profiles, do: data(profile))}
  end

  @doc """
  Renders a single profile.
  """
  def show(%{profile: profile}) do
    %{data: data(profile)}
  end

  defp data(%Profile{} = profile) do
    %{
      id: profile.id,
      user_id: profile.user_id,
      name: profile.name
    }
  end
end
