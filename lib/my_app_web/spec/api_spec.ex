defmodule MyAppWeb.ApiSpec do
  alias OpenApiSpex.{Info, OpenApi, Paths, Server, SecurityScheme, Components}
  alias MyAppWeb.{Router}
  @behaviour OpenApi

  @impl OpenApi
  def spec do
    %OpenApi{
      servers: [
        # Populate the Server info from a phoenix endpoint
        %Server{url: "http://localhost:4000"}
      ],
      info: %Info{
        title: "My App",
        version: "1.0"
      },
      # Populate the paths from a phoenix router
      paths: Paths.from_router(Router),
      components: %Components{
        securitySchemes: %{
          "authorization" => %SecurityScheme{type: "http", scheme: "bearer"}
        }
      },
    }
    |> OpenApiSpex.resolve_schema_modules()
  end
end
