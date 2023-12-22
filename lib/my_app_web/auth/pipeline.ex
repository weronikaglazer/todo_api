defmodule MyAppWeb.Auth.Pipeline do
  use Guardian.Plug.Pipeline,
    otp_app: :real_api,
    module: MyAppWeb.Auth.Guardian,
    error_handler: MyAppWeb.Auth.ErrorHandler

  plug Guardian.Plug.VerifySession
  plug Guardian.Plug.VerifyHeader
  plug Guardian.Plug.EnsureAuthenticated
  plug Guardian.Plug.LoadResource
end
