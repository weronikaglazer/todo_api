defmodule MyAppWeb.UserJSON do
  alias MyApp.Users.User
  #alias MyAppWeb.ProfileJSON

  @doc """
  Renders a list of users.
  """
  def index(%{users: users}) do
    %{data: for(user <- users, do: data(user))}
  end

  @doc """
  Renders a single user.
  """
  def show(%{user: user}) do
    %{data: data(user)}
  end

  defp data(%User{} = user) do
    %{
      id: user.id,
      mobile: user.mobile,
      email: user.email,
      task_ids: user.task_ids
    }
  end

  def user_token(%{user: user, token: token}) do
    %{
      id: user.id,
      mobile: user.mobile,
      email: user.email,
      task_ids: user.task_ids,
      token: token
    }
  end
end
