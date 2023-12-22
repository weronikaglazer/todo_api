defmodule MyAppWeb.UserControllerTest do
  use MyAppWeb.ConnCase, async: true
  use MyApp.RepoCase
  alias MyAppWeb.Auth.ErrorResponse
  @endpoint MyAppWeb.Endpoint

  @create_attrs %{
    "user" => %{
      "mobile" => "123456777",
      "email" => "test@test.com",
      "password_hash" => Bcrypt.hash_pwd_salt("testpassword"),
      "info" => %{}
    }
  }

  @update_attrs %{
    "user" => %{
      "mobile" => "098765432",
      "email" => "updated@email.com",
    }
  }

  @invalid_attrs %{
      "user" => %{
        "invalid_param" => "somevalue"
      }
  }

  @invalid_request %{
    "notuserparameter" => "invalid"
  }

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "content-type", "application/json")}
  end

  describe "index" do
    test "GET /api/users", %{conn: conn} do
      conn = get(conn, ~p"/api/users")
      assert json_response(conn, 200)["data"]
    end
  end

  describe "register" do
    test "POST /user/register with valid input", %{conn: conn} do
      conn =
        conn
        |> post(~p"/api/user/register", Jason.encode!(@create_attrs))


      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/api/users")
      users = json_response(conn, 200)["data"]

      assert Enum.any?(users, &Map.has_key?(&1, "id") and &1["id"] == id)
    end

    test "POST /user/register with invalid user parameters", %{conn: conn} do
      conn =
        conn
        |> post(~p"/api/user/register", Jason.encode!(@invalid_attrs))

      assert json_response(conn, 400)["errors"] != %{}
    end

    test "POST /user/register with no user parameter", %{conn: conn} do
      conn =
        conn
        |> post(~p"/api/user/register", Jason.encode!(@invalid_request))

      assert json_response(conn, 400)["errors"] != %{}
    end

    test "POST /user/register with email already taken", %{conn: conn} do
      register_user1_response =
        conn
        |> post(~p"/api/user/register", Jason.encode!(@create_attrs))


      assert %{"id" => id, "email" => email} = json_response(register_user1_response, 201)["data"]

      get_users_response = get(conn, ~p"/api/users")
      users = json_response(get_users_response, 200)["data"]

      assert Enum.any?(users, &Map.has_key?(&1, "id") and &1["id"] == id)

      register_user2_response =
        conn
        |> post(~p"/api/user/register", Jason.encode!(%{"user" => %{
          "mobile" => "445889123",
          "email" => email,
          "password_hash" => Bcrypt.hash_pwd_salt("testpassword"),
          "info" => %{}
        }}))

      assert json_response(register_user2_response, 422)["errors"] != %{}
    end

    test "POST /user/register with mobile already taken", %{conn: conn} do
      register_user1_response =
        conn
        |> post(~p"/api/user/register", Jason.encode!(@create_attrs))


      assert %{"id" => id, "mobile" => mobile} = json_response(register_user1_response, 201)["data"]

      get_users_response = get(conn, ~p"/api/users")
      users = json_response(get_users_response, 200)["data"]

      assert Enum.any?(users, &Map.has_key?(&1, "id") and &1["id"] == id)

      register_user2_response =
        conn
        |> post(~p"/api/user/register", Jason.encode!(%{"user" => %{
          "mobile" => mobile,
          "email" => "testdifferent@test.com",
          "password_hash" => Bcrypt.hash_pwd_salt("testpassword"),
          "info" => %{}
        }}))

      assert json_response(register_user2_response, 422)["errors"] != %{}
    end

    test "POST /user/register with email and mobile already taken", %{conn: conn} do
      register_user1_response =
        conn
        |> post(~p"/api/user/register", Jason.encode!(@create_attrs))


      assert %{"id" => id} = json_response(register_user1_response, 201)["data"]

      get_users_response = get(conn, ~p"/api/users")
      users = json_response(get_users_response, 200)["data"]

      assert Enum.any?(users, &Map.has_key?(&1, "id") and &1["id"] == id)

      register_user2_response =
        conn
        |> post(~p"/api/user/register", Jason.encode!(@create_attrs))

      assert json_response(register_user2_response, 422)["errors"] != %{}
    end

  end

  describe "login" do
    test "POST /user/login with valid email", %{conn: conn} do
      conn =
        conn
        |> post(~p"/api/user/login", Jason.encode!(%{"email" => "user1@test.com", "password_hash" => "password1"}))

      assert json_response(conn, 200)
    end

    test "POST /user/login with valid mobile", %{conn: conn} do
      conn =
        conn
        |> post(~p"/api/user/login", Jason.encode!(%{"mobile" => "987654321", "password_hash" => "password1"}))

      assert json_response(conn, 200)
    end

    test "POST /user/login with invalid credentials", %{conn: conn} do
      assert_raise ErrorResponse.Unauthorized, fn ->
        conn
        |> post(~p"/api/user/login", Jason.encode!(%{"mobile" => "987654321", "password_hash" => "wrongpassword"}))
      end
    end

    test "POST /user/login with missing credential", %{conn: conn} do
      conn =
        conn
        |> post(~p"/api/user/login", Jason.encode!(%{"password_hash" => "password1"}))

      assert json_response(conn, 400)["errors"] != %{}
    end
  end

  describe "refresh_session" do
    test "GET /user/refresh when user is logged in", %{conn: conn} do
      login_response =
        conn
        |> post(~p"/api/user/login", Jason.encode!(%{"email" => "user1@test.com", "password_hash" => "password1"}))

      assert %{"token" => token} = json_response(login_response, 200)

      refresh_response =
        conn
        |> put_req_header("authorization", "Bearer #{token}")
        |> get(~p"/api/user/refresh")

      assert %{"token" => new_token} = json_response(refresh_response, 200)
      assert token != new_token

      current_response_with_invalid_token =
        conn
        |> put_req_header("authorization", "Bearer #{token}")
        |> get(~p"/api/user/current")

      assert json_response(current_response_with_invalid_token, 401)

      current_response_with_valid_token =
        conn
        |> put_req_header("authorization", "Bearer #{new_token}")
        |> get(~p"/api/user/current")

        assert %{"email" => "user1@test.com"} = json_response(current_response_with_valid_token, 200)["data"]
    end

    test "GET /user/refresh when no user is logged in", %{conn: conn} do
      conn =
        conn
        |> put_req_header("authorization", "Bearer sometoken")
        |> get(~p"/api/user/refresh")

      assert json_response(conn, 401)
    end
  end

  describe "logout" do
    test "POST /user/logout when user is logged in" , %{conn: conn} do
      login_response =
        conn
        |> post(~p"/api/user/login", Jason.encode!(%{"email" => "user1@test.com", "password_hash" => "password1"}))

      assert %{"token" => token} = json_response(login_response, 200)

      logout_response =
        conn
        |> put_req_header("authorization", "Bearer #{token}")
        |> post(~p"/api/user/logout")

      assert json_response(logout_response, 200)
    end

    test "POST /user/logout when user is not logged in" , %{conn: conn} do
      conn =
        conn
        |> put_req_header("authorization", "Bearer somewrongtoken")
        |> post("/api/user/logout")

      assert json_response(conn, 401)
    end
  end

  describe "current_user" do
    test "GET /user/current when user is logged in",  %{conn: conn} do
      login_response =
        conn
        |> post(~p"/api/user/login", Jason.encode!(%{"email" => "user1@test.com", "password_hash" => "password1"}))
      assert %{"token" => token} = json_response(login_response, 200)

      current_response =
        conn
        |> put_req_header("authorization", "Bearer #{token}")
        |> get(~p"/api/user/current")

      assert %{"email" => "user1@test.com"} = json_response(current_response, 200)["data"]
    end

    test "GET /user/current when no user is logged in", %{conn: conn} do
      conn =
        conn
        |> put_req_header("authorization", "Bearer sometoken")
        |> get("/api/user/current")

      assert json_response(conn, 401)
    end
  end

  describe "update" do
    test "PUT /user/update with valid parameters", %{conn: conn} do
      login_response =
        conn
        |> post(~p"/api/user/login", Jason.encode!(%{"email" => "user1@test.com", "password_hash" => "password1"}))
      assert %{"token" => token} = json_response(login_response, 200)

      update_response =
        conn
        |> put_req_header("authorization", "Bearer #{token}")
        |> put(~p"/api/user/update", Jason.encode!(@update_attrs))
      assert %{"email" => "updated@email.com"} = json_response(update_response, 200)["data"]
    end

    test "PUT /user/update with invalid parameters", %{conn: conn} do
      login_response =
        conn
        |> post(~p"/api/user/login", Jason.encode!(%{"email" => "user1@test.com", "password_hash" => "password1"}))
      assert %{"token" => token} = json_response(login_response, 200)

      update_response =
        conn
        |> put_req_header("authorization", "Bearer #{token}")
        |> put(~p"/api/user/update", Jason.encode!(%{"user" => %{"invalid_parameter" => "value"}}))

      assert json_response(update_response, 400)["errors"] != %{}
    end

    test "PUT /user/update when no user is logged in", %{conn: conn} do
      conn =
        conn
        |> put_req_header("authorization", "Bearer somewrongtoken")
        |> put("/api/user/update")

      assert json_response(conn, 401)
    end
  end

  describe "delete user" do
    test "DELETE /user/delete when user is logged in", %{conn: conn} do
      login_response =
        conn
        |> post(~p"/api/user/login", Jason.encode!(%{"email" => "user1@test.com", "password_hash" => "password1"}))

      assert %{"token" => token} = json_response(login_response, 200)

      delete_response =
        conn
        |> put_req_header("authorization", "Bearer #{token}")
        |> delete(~p"/api/user/delete", Jason.encode!(%{"user" => %{"password" => "password1"}}))

      assert response(delete_response, 204)

      current_response =
        conn
        |> put_req_header("authorization", "Bearer #{token}")
        |> get("/api/user/current")

      assert json_response(current_response, 401)
    end

    test "DELETE /user/delete when password is invalid", %{conn: conn} do
      login_response =
        conn
        |> post(~p"/api/user/login", Jason.encode!(%{"email" => "user1@test.com", "password_hash" => "password1"}))

      assert %{"token" => token} = json_response(login_response, 200)

      assert_raise ErrorResponse.Unauthorized, fn ->
        _delete_response =
          conn
          |> put_req_header("authorization", "Bearer #{token}")
          |> delete(~p"/api/user/delete", Jason.encode!(%{"user" => %{"password" => "wrongpassword"}}))
      end

      current_response =
        conn
        |> put_req_header("authorization", "Bearer #{token}")
        |> get("/api/user/current")

        %{"email" => "user1@test.com"} = json_response(current_response, 200)["data"]
    end

    test "DELETE /user/delete when request is invalid", %{conn: conn} do
      login_response =
        conn
        |> post(~p"/api/user/login", Jason.encode!(%{"email" => "user1@test.com", "password_hash" => "password1"}))

      assert %{"token" => token} = json_response(login_response, 200)

      delete_response =
        conn
        |> put_req_header("authorization", "Bearer #{token}")
        |> delete(~p"/api/user/delete", Jason.encode!(@invalid_request))

      assert json_response(delete_response, 400)["errors"] != %{}
    end

    test "DELETE /user/delete when no user is logged in", %{conn: conn} do
      conn =
        conn
        |> put_req_header("authorization", "Bearer somewrongtoken")
        |> delete("/api/user/delete")

      assert json_response(conn, 401)
    end
  end
end
