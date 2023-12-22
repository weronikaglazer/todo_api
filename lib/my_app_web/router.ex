defmodule MyAppWeb.Router do
  use MyAppWeb, :router
  use Plug.ErrorHandler
  alias MyAppWeb.{TaskController, UserController, ProfileController, FileController}

  def handle_error(conn, %{reason: %Phoenix.Router.NoRouteError{message: message}}) do
    conn |> json(%{erorrs: message}) |> halt()
  end

  def handle_errors(conn, %{reason: %{message: message}}) do
    conn |> json(%{errors: message}) |> halt()
  end

  def handle_errors(conn, _) do
    conn |> json(%{errors: %{detail: "Something went wrong"}}) |> halt()
  end

  pipeline :browser do
    plug :fetch_session
    plug :accepts, ["html"]
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug :fetch_session
    plug OpenApiSpex.Plug.PutApiSpec, module: MyAppWeb.ApiSpec
  end

  pipeline :auth do
    plug MyAppWeb.Auth.Pipeline
  end

  scope "/" do
    pipe_through :browser
    get "/swaggerui", OpenApiSpex.Plug.SwaggerUI, path: "/api/openapi"
  end

  scope "/api" do
    pipe_through :api

    get "/openapi", OpenApiSpex.Plug.RenderSpec, []

    get "/users", UserController, :index
    post "/user/register", UserController, :register
    post "/user/login", UserController, :login

    post "/tasks/search", TaskController, :search
  end

  scope "/api" do
    pipe_through [:api, :auth]

    # File routes
    put "/tasks/:task_id/files/:file_id/rename", FileController, :rename
    get "/tasks/:task_id/files/:file_id/download", FileController, :download
    delete "/tasks/:task_id/files/:file_id/delete", FileController, :delete

    # Tasks routes
    get "/tasks", TaskController, :index
    get "/tasks/search/:id", TaskController, :show
    post "/tasks/create", TaskController, :create
    put "/tasks/update/:id", TaskController, :update
    delete "/tasks/delete/:id", TaskController, :delete
    post "/tasks/:id/files/upload", FileController, :upload

    # User routes
    get "/user/current", UserController, :current_user
    put "/user/update", UserController, :update
    post "/user/logout", UserController, :logout
    get "/user/refresh", UserController, :refresh_session
    delete "/user/delete", UserController, :delete

    # Profile routes
    post "/profile/create", ProfileController, :create
    get "/profile/current", ProfileController, :current
    put "/profile/update", ProfileController, :update
    delete "/profile/delete", ProfileController, :delete
  end
end
