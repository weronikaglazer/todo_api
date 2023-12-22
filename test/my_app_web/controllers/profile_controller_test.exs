defmodule MyAppWeb.ProfileControllerTest do
  use MyAppWeb.ConnCase, async: true
  use MyApp.RepoCase
  @endpoint MyAppWeb.Endpoint

  @create_attrs %{
      "profile" => %{
        "name" => "user1profilename"
      }
  }

  @update_attrs %{
    "profile" => %{
      "name" => "updateduser1name"
    }
  }

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "content-type", "application/json")}
  end


  describe "create" do
    test "POST /profile/create when user has no profile and request is valid", %{conn: conn} do
      login_response =
        conn
        |> post(~p"/api/user/login", Jason.encode!(%{"email" => "user1@test.com", "password_hash" => "password1"}))

      assert %{"token" => token} = json_response(login_response, 200)

      create_profile_response =
        conn
        |> put_req_header("authorization", "Bearer #{token}")
        |> post(~p"/api/profile/create", Jason.encode!(@create_attrs))

      assert %{"user_id" => 1} = json_response(create_profile_response, 201)["data"]
    end

    test "POST /profile/create when user has no profile and parameters are invalid", %{conn: conn} do
      login_response =
        conn
        |> post(~p"/api/user/login", Jason.encode!(%{"email" => "user1@test.com", "password_hash" => "password1"}))

      assert %{"token" => token} = json_response(login_response, 200)

      create_profile_response =
        conn
        |> put_req_header("authorization", "Bearer #{token}")
        |> post(~p"/api/profile/create", Jason.encode!(%{"profile" => %{"wrong_parameter" => "value"}}))

      assert json_response(create_profile_response, 400)["errors"] != %{}
    end

    test "POST /profile/create when user has no profile and request is invalid", %{conn: conn} do
      login_response =
        conn
        |> post(~p"/api/user/login", Jason.encode!(%{"email" => "user1@test.com", "password_hash" => "password1"}))

      assert %{"token" => token} = json_response(login_response, 200)

      create_profile_response =
        conn
        |> put_req_header("authorization", "Bearer #{token}")
        |> post(~p"/api/profile/create", Jason.encode!(%{"wrong_request" => %{}}))

      assert json_response(create_profile_response, 400)["errors"] != %{}
    end

    test "POST /profile/create when user already has a profile", %{conn: conn} do
      login_response =
        conn
        |> post(~p"/api/user/login", Jason.encode!(%{"email" => "user1@test.com", "password_hash" => "password1"}))

      assert %{"token" => token} = json_response(login_response, 200)

      create_profile_response =
        conn
        |> put_req_header("authorization", "Bearer #{token}")
        |> post(~p"/api/profile/create", Jason.encode!(@create_attrs))

      assert %{"user_id" => 1} = json_response(create_profile_response, 201)["data"]

      create_second_profile_response =
        conn
        |> put_req_header("authorization", "Bearer #{token}")
        |> post(~p"/api/profile/create", Jason.encode!(@create_attrs))

      assert json_response(create_second_profile_response, 409)["errors"] != %{}
    end

    test "POST /profile/create when no user is logged in", %{conn: conn} do
      create_profile_response =
        conn
        |> put_req_header("authorization", "Bearer sometoken")
        |> post(~p"/api/profile/create", Jason.encode!(@create_attrs))

      assert json_response(create_profile_response, 401)
    end


  end

  describe "current" do
    test "GET /api/profile/current when profile exists for logged in user", %{conn: conn} do
      login_response =
        conn
        |> post(~p"/api/user/login", Jason.encode!(%{"email" => "user1@test.com", "password_hash" => "password1"}))

      assert %{"token" => token} = json_response(login_response, 200)

      create_profile_response =
        conn
        |> put_req_header("authorization", "Bearer #{token}")
        |> post(~p"/api/profile/create", Jason.encode!(@create_attrs))

      assert %{"user_id" => 1} = json_response(create_profile_response, 201)["data"]

      current_profile_response =
        conn
        |> put_req_header("authorization", "Bearer #{token}")
        |> get(~p"/api/profile/current")

      assert %{"user_id" => 1} = json_response(current_profile_response, 200)["data"]
    end

    test "GET /api/profile/current when profile doesn't exist for logged in user", %{conn: conn} do
      login_response =
        conn
        |> post(~p"/api/user/login", Jason.encode!(%{"email" => "user1@test.com", "password_hash" => "password1"}))

      assert %{"token" => token} = json_response(login_response, 200)

      current_profile_response =
        conn
        |> put_req_header("authorization", "Bearer #{token}")
        |> get(~p"/api/profile/current")

      assert json_response(current_profile_response, 404)["errors"] != %{}
    end

    test "GET /api/profile/current when no user is logged in", %{conn: conn} do
      conn =
        conn
        |> put_req_header("authorization", "Bearer sometoken")
        |> get(~p"/api/profile/current")

      assert json_response(conn, 401)
    end
  end

  describe "update" do
    test "PUT /profile/update when user has a profile and parameters are valid", %{conn: conn} do
      login_response =
        conn
        |> post(~p"/api/user/login", Jason.encode!(%{"email" => "user1@test.com", "password_hash" => "password1"}))

      assert %{"token" => token} = json_response(login_response, 200)

      create_profile_response =
        conn
        |> put_req_header("authorization", "Bearer #{token}")
        |> post(~p"/api/profile/create", Jason.encode!(@create_attrs))

      assert %{"user_id" => 1} = json_response(create_profile_response, 201)["data"]

      update_profile_response =
        conn
        |> put_req_header("authorization", "Bearer #{token}")
        |> put(~p"/api/profile/update", Jason.encode!(@update_attrs))

      assert %{"name" => "updateduser1name"} = json_response(update_profile_response, 200)["data"]
    end

    test "PUT /profile/update when user has a profile and parameters are invalid", %{conn: conn} do
      login_response =
        conn
        |> post(~p"/api/user/login", Jason.encode!(%{"email" => "user1@test.com", "password_hash" => "password1"}))

      assert %{"token" => token} = json_response(login_response, 200)

      create_profile_response =
        conn
        |> put_req_header("authorization", "Bearer #{token}")
        |> post(~p"/api/profile/create", Jason.encode!(@create_attrs))

      assert %{"user_id" => 1} = json_response(create_profile_response, 201)["data"]

      update_profile_response =
        conn
        |> put_req_header("authorization", "Bearer #{token}")
        |> put(~p"/api/profile/update", Jason.encode!(%{"profile" => %{"invalid_param" => 34243}}))

      assert json_response(update_profile_response, 400)["errors"] != %{}
    end

    test "PUT /profile/update when user has a profile and request is invalid", %{conn: conn} do
      login_response =
        conn
        |> post(~p"/api/user/login", Jason.encode!(%{"email" => "user1@test.com", "password_hash" => "password1"}))

      assert %{"token" => token} = json_response(login_response, 200)

      create_profile_response =
        conn
        |> put_req_header("authorization", "Bearer #{token}")
        |> post(~p"/api/profile/create", Jason.encode!(@create_attrs))

      assert %{"user_id" => 1} = json_response(create_profile_response, 201)["data"]

      update_profile_response =
        conn
        |> put_req_header("authorization", "Bearer #{token}")
        |> put(~p"/api/profile/update", Jason.encode!(%{"invalid_body" => 89675}))

      assert json_response(update_profile_response, 400)["errors"] != %{}
    end

    test "PUT /profile/update when user has no profile", %{conn: conn} do
      login_response =
        conn
        |> post(~p"/api/user/login", Jason.encode!(%{"email" => "user1@test.com", "password_hash" => "password1"}))

      assert %{"token" => token} = json_response(login_response, 200)

      update_profile_response =
        conn
        |> put_req_header("authorization", "Bearer #{token}")
        |> put(~p"/api/profile/update", Jason.encode!(@update_attrs))

      assert json_response(update_profile_response, 404)["errors"] != %{}
    end

    test "PUT /profile/update when no user is logged in", %{conn: conn} do
      conn =
        conn
        |> put_req_header("authorization", "Bearer sometoken")
        |> put(~p"/api/profile/update", Jason.encode!(@update_attrs))

      assert json_response(conn, 401)
    end
  end

  describe "delete" do
    test "DELETE /profile/delete when user has a profile", %{conn: conn} do
      login_response =
        conn
        |> post(~p"/api/user/login", Jason.encode!(%{"email" => "user1@test.com", "password_hash" => "password1"}))

      assert %{"token" => token} = json_response(login_response, 200)

      create_profile_response =
        conn
        |> put_req_header("authorization", "Bearer #{token}")
        |> post(~p"/api/profile/create", Jason.encode!(@create_attrs))

      assert %{"user_id" => 1} = json_response(create_profile_response, 201)["data"]

      delete_profile_response =
        conn
        |> put_req_header("authorization", "Bearer #{token}")
        |> delete(~p"/api/profile/delete")

      assert response(delete_profile_response, 204)
    end

    test "DELETE /profile/delete when user has no profile", %{conn: conn} do
      login_response =
        conn
        |> post(~p"/api/user/login", Jason.encode!(%{"email" => "user1@test.com", "password_hash" => "password1"}))

      assert %{"token" => token} = json_response(login_response, 200)

      delete_profile_response =
        conn
        |> put_req_header("authorization", "Bearer #{token}")
        |> delete(~p"/api/profile/delete")

      assert json_response(delete_profile_response, 404)["errors"] != %{}
    end

    test "DELETE /profile/delete when no user is logged in", %{conn: conn} do
      conn =
        conn
        |> put_req_header("authorization", "Bearer sometoken")
        |> delete(~p"/api/profile/delete")

      assert json_response(conn, 401)
    end
  end
end
