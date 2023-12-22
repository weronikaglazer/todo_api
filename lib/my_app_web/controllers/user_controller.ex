defmodule MyAppWeb.UserController do
  use MyAppWeb, :controller
  use OpenApiSpex.ControllerSpecs
  alias MyAppWeb.Schemas
  alias MyAppWeb.Auth.{Guardian, ErrorResponse}
  alias MyApp.{Users, Users.User, ElasticsearchService}

  action_fallback MyAppWeb.FallbackController
  tags ["User Controller"]


  operation :index,
    summary: "Lists all users",
    request_body: {},
    responses: %{
      200 => {"Users listed", "application/json", Schemas.UsersResponse}
    }

  def index(conn, _params) do
    users = Users.list_users()
    render(conn, :index, users: users)
  end

  operation :register,
    summary: "Registers a new user",
    request_body: {"User register request body", "application/json", Schemas.UserRegisterReqBody},
    responses: %{
      200 => {"User registered", "application/json", Schemas.UserResponse},
      400 => {"Request invalid", "application/json", Schemas.BadRequest}
    }
  def register(conn, user_params) do
    available_params = ["email", "mobile", "password_hash", "info"]

    case validate_params(user_params, available_params) do
      {:ok, params} ->
        with {:ok, %User{} = user} <- Users.create_user(params) do
          conn
          |> put_status(:created)
          |> render(:show, %{user: user})
        end
      {:error, _reason} -> {:error, :bad_request}
    end
  end

  operation :login,
    summary: "Logs into a user account",
      request_body: {"User register request body", "application/json", Schemas.UserLoginReqBody},
      responses: %{
        200 => {"User logged in", "application/json", Schemas.UserWithToken},
        400 => {"Request invalid", "application/json", Schemas.BadRequest},
        401 => {"Invalid credentials", "application/json", Schemas.Unauthorized}
      }

  def login(conn, credentials) do
    case credentials do
      %{"email" => email, "password_hash" => password_hash} ->
        case Guardian.authenticate(email, "email", password_hash) do
          {:ok, user, token} ->
            conn
            |> put_status(:ok)
            |> render(:user_token, %{user: user, token: token})
          {:error, :unauthorized} -> raise ErrorResponse.Unauthorized, message: "Email or Password incorrect."
        end
      %{"mobile" => mobile, "password_hash" => password_hash} ->
          case Guardian.authenticate(mobile, "mobile", password_hash) do
            {:ok, user, token} ->
              conn
              |> put_status(:ok)
              |> render(:user_token, %{user: user, token: token})
            {:error, :unauthorized} -> raise ErrorResponse.Unauthorized, message: "Mobile or Password incorrect."
          end
        _ -> {:error, :bad_request}
    end
  end

  operation :refresh_session,
    summary: "Refreshes the current session",
    request_body: {},
    responses: %{
      200 => {"Session refreshed", "application/json", Schemas.UserWithToken},
      401 => {"No user is logged in", "application/json", Schemas.Unauthorized}
    },
    security: [%{"authorization" => []}]
  def refresh_session(conn, _params) do
    token = Guardian.Plug.current_token(conn)
    {:ok, user, new_token} = Guardian.authenticate(token)
    conn
    |> put_status(:ok)
    |> render(:user_token, %{user: user, token: new_token})
  end

  operation :logout,
    summary: "Logs out currently logged in user",
    request_body: {},
    responses: %{
      200 => {"User logged out", "application/json", Schemas.UserWithToken},
      401 => {"No user is logged in", "application/json", Schemas.Unauthorized}
    },
    security: [%{"authorization" => []}]

  def logout(conn, _params) do
    user = Guardian.Plug.current_resource(conn)
    token = Guardian.Plug.current_token(conn)
    Guardian.revoke(token)

    conn
    |> put_status(:ok)
    |> render(:show, %{user: user})
  end

  operation :current_user,
    summary: "Renders the currently logged in user",
    request_body: {},
    responses: %{
      200 => {"User rendered", "application/json", Schemas.UserResponse},
      401 => {"No user is logged in", "application/json", Schemas.Unauthorized}
    },
    security: [%{"authorization" => []}]

  def current_user(conn, _params) do
    user = Guardian.Plug.current_resource(conn)
    render(conn, :show, user: user)
  end

  operation :update,
    summary: "Updates the current user's data",
    request_body: {"User update request body", "application/json", Schemas.UserUpdateReqBody},
    responses: %{
      200 => {"User updated", "application/json", Schemas.UserResponse},
      400 => {"Request invalid", "application/json", Schemas.BadRequest},
      401 => {"No user is logged in", "application/json", Schemas.Unauthorized}
    },
    security: [%{"authorization" => []}]

  def update(conn, user_params) do
    user = Guardian.Plug.current_resource(conn)
    available_params = ["mobile", "email", "password_hash", "info"]

    case validate_params(user_params, available_params) do
      {:ok, params} ->
        with {:ok, %User{} = user} <- Users.update_user(user, params) do
          render(conn, :show, user: user)
        end
      {:error, _reason} -> {:error, :bad_request}
    end
  end

  operation :delete,
    summary: "Deletes the currently logged in user",
    request_body: {"User delete request body", "application/json", Schemas.UserDeleteReqBody},
    responses: %{
      204 => {"User deleted", "application/json", Schemas.NoContent},
      401 => {"No user is logged in or password is wrong", "application/json", Schemas.Unauthorized},
      400 => {"Invalid request body", "application/json", Schemas.BadRequest}
    },
    security: [%{"authorization" => []}]

  def delete(conn, user_params) do
    user = Guardian.Plug.current_resource(conn)
    available_params = ["password"]

    case validate_params(user_params, available_params) do
      {:ok, params} ->
        case Guardian.validate_password(params["password"], user.password_hash) do
          true ->
            with {:ok, %User{}} <- Users.delete_user(user),
                  :ok <- ElasticsearchService.delete_user_tasks(user.id),
                  token <- Guardian.Plug.current_token(conn),
                  {:ok, _claims} <- Guardian.revoke(token),
                  {:ok, _} <- File.rm_rf("priv/static/uploads/user#{user.id}") do
              send_resp(conn, :no_content, "")
            end
          false ->
            raise ErrorResponse.Unauthorized, message: "Password incorrect"
        end
      {:error, _reason} -> {:error, :bad_request}
    end
  end


  defp validate_params(user_params, available_params) do
    case user_params do
        %{"user" => user_params_map} when is_map(user_params_map) and map_size(user_params_map) > 0 ->
              params_valid? = Enum.all?(Map.keys(user_params_map), &(&1 in available_params))
              if params_valid? do
                {:ok, user_params_map}
              else
                {:error, "Invalid parameters"}
              end
        _ ->
          {:error, "Invalid request body"}
    end
  end
end
