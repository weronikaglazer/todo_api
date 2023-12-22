defmodule MyAppWeb.ProfileController do
  use MyAppWeb, :controller
  use OpenApiSpex.ControllerSpecs
  alias MyAppWeb.Schemas
  alias MyApp.{Profiles, Profiles.Profile}

  action_fallback MyAppWeb.FallbackController
  tags ["Profile Controller"]

  security [%{"authorization" => []}]

  operation :create,
    summary: "Creates a profile for logged in user",
    request_body: {"Create profile request body", "application/json", Schemas.ProfileCreateOrUpdateReqBody},
    responses: %{
      201 => {"Profile created", "application/json", Schemas.ProfileResponse},
      400 => {"Request invalid", "application/json", Schemas.BadRequest},
      409 => {"Profile already exists", "application/json", Schemas.Conflict},
      401 => {"No user is logged in", "application/json", Schemas.Unauthorized}
    }

  def create(conn, profile_params) do
    user = Guardian.Plug.current_resource(conn)
    profile = Profiles.get_profile_by_user_id!(user.id)

    case validate_params(profile_params) do
      {:ok, params} ->
        case profile do
          nil ->
            with {:ok, %Profile{} = created_profile} <- Profiles.create_profile(user, params) do
              conn
              |> put_status(:created)
              |> render(:show, profile: created_profile)
            end
          %Profile{} -> {:error, :conflict}
        end
      {:error, _reason} -> {:error, :bad_request}
    end

  end


  operation :current,
    summary: "Shows the user's profile",
      request_body: {},
      responses: %{
        200 => {"Profile rendered", "application/json", Schemas.ProfileResponse},
        404 => {"Profile not found", "application/json", Schemas.NotFound},
        401 => {"No user is logged in", "application/json", Schemas.Unauthorized}
      }

  def current(conn, %{}) do
    user = Guardian.Plug.current_resource(conn)
    profile = Profiles.get_profile_by_user_id!(user.id)

    case profile do
      %Profile{} -> render(conn, :show, profile: profile)
      nil -> {:error, :not_found}
    end
  end


  operation :update,
    summary: "Updates the user's profile",
    request_body: {"Update profile request body", "application/json", Schemas.ProfileCreateOrUpdateReqBody},
    responses: %{
      200 => {"Profile updated", "application/json", Schemas.ProfileResponse},
      400 => {"Invalid request", "application/json", Schemas.BadRequest},
      404 => {"Profile not found", "application/json", Schemas.NotFound},
      401 => {"No user is logged in", "application/json", Schemas.Unauthorized}
    }

  def update(conn, profile_params) do
    user = Guardian.Plug.current_resource(conn)
    profile = Profiles.get_profile_by_user_id!(user.id)

    case validate_params(profile_params) do
      {:ok, params} ->
        case profile do
          %Profile{} ->
            with {:ok, %Profile{} = updated_profile} <- Profiles.update_profile(profile, params) do
              render(conn, :show, profile: updated_profile)
            end
          nil -> {:error, :not_found}
        end
      {:error, _reason} ->
        {:error, :bad_request}
    end
  end

  operation :delete,
    summary: "Deletes the user's profile",
    request_body: {},
    responses: %{
      204 => {"User deleted", "application/json", Schemas.NoContent},
      404 => {"Profile not found", "application/json", Schemas.NotFound},
      401 => {"No user is logged in", "application/json", Schemas.Unauthorized}
    }

  def delete(conn, %{}) do
    user = Guardian.Plug.current_resource(conn)
    profile = Profiles.get_profile_by_user_id!(user.id)

    case profile do
      %Profile{} ->
        with {:ok, %Profile{}} <- Profiles.delete_profile(profile) do
          send_resp(conn, :no_content, "")
        end
      nil -> {:error, :not_found}
    end
  end

  defp validate_params(profile_params) do
    available_params = ["name"]

    case profile_params do
      %{"profile" => params} when is_map(params) and map_size(params) > 0 ->
          params_valid? = Enum.all?(Map.keys(params), &(&1 in available_params))

          if params_valid? do
            {:ok, params}
          else
            {:error, "Invalid parameters"}
          end
      _ -> {:error, "Invalid request body"}
    end
  end
end
