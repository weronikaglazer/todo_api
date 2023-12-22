defmodule MyAppWeb.TaskControllerTest do
  use MyAppWeb.ConnCase, async: true
  use MyApp.RepoCase
  @endpoint MyAppWeb.Endpoint


  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "content-type", "application/json")}
  end

  @create_attrs %{
    "title" => "Get groceries",
    "description" => "List: bread, apples, milk"
  }

  @update_attrs %{
    "title" => "Get groceries from the market",
    "completed" => true
  }

  @invalid_attrs %{
    "some_wrong_parameter" => "value"
  }

  describe "index" do
    test "GET /api/tasks when user has tasks", %{conn: conn} do
      login_response =
        conn
        |> post(~p"/api/user/login", Jason.encode!(%{"email" => "user1@test.com", "password_hash" => "password1"}))

        assert %{"token" => token} = json_response(login_response, 200)

        create_task_response =
          conn
          |> put_req_header("authorization", "Bearer #{token}")
          |> post(~p"/api/tasks/create", Jason.encode!(@create_attrs))

        assert json_response(create_task_response, 201)["task"]

        list_tasks_response =
          conn
          |> put_req_header("authorization", "Bearer #{token}")
          |> get(~p"/api/tasks")

        assert json_response(list_tasks_response, 200)["tasks"] != []
    end

    test "GET /api/tasks when user has no tasks", %{conn: conn} do
      login_response =
        conn
        |> post(~p"/api/user/login", Jason.encode!(%{"email" => "user1@test.com", "password_hash" => "password1"}))

        assert %{"token" => token} = json_response(login_response, 200)

        list_tasks_response =
          conn
          |> put_req_header("authorization", "Bearer #{token}")
          |> get(~p"/api/tasks")

        assert json_response(list_tasks_response, 404)["errors"] != %{}
    end

    test "GET /api/tasks when no user is logged in", %{conn: conn} do
      create_task_response =
        conn
        |> put_req_header("authorization", "Bearer sometoken")
        |> get(~p"/api/tasks")

      assert json_response(create_task_response, 401)
    end
  end

  describe "show" do
    test "GET /api/tasks/search/:id when id is valid", %{conn: conn} do
      login_response =
        conn
        |> post(~p"/api/user/login", Jason.encode!(%{"email" => "user1@test.com", "password_hash" => "password1"}))

        assert %{"token" => token} = json_response(login_response, 200)

      create_task_response =
        conn
        |> put_req_header("authorization", "Bearer #{token}")
        |> post(~p"/api/tasks/create", Jason.encode!(@create_attrs))

      assert %{"id" => id} = json_response(create_task_response, 201)["task"]

      show_task_response =
        conn
        |> put_req_header("authorization", "Bearer #{token}")
        |> get(~p"/api/tasks/search/#{id}")

      assert %{"id" => ^id} = json_response(show_task_response, 200)["task"]
    end

    test "GET /api/tasks/search/:id when id is invalid", %{conn: conn} do
      login_response =
        conn
        |> post(~p"/api/user/login", Jason.encode!(%{"email" => "user1@test.com", "password_hash" => "password1"}))

        assert %{"token" => token} = json_response(login_response, 200)

      show_task_response =
        conn
        |> put_req_header("authorization", "Bearer #{token}")
        |> get(~p"/api/tasks/search/67")

      assert json_response(show_task_response, 404)["errors"] != %{}
    end

    test "GET /api/tasks/search/:id when no user is logged in", %{conn: conn} do
      show_task_response =
        conn
        |> put_req_header("authorization", "Bearer sometoken")
        |> get(~p"/api/tasks/search/67")

      assert json_response(show_task_response, 401)
    end
  end

  describe "create" do
    test "POST /api/tasks/create when input is valid", %{conn: conn} do
        login_response =
          conn
          |> post(~p"/api/user/login", Jason.encode!(%{"email" => "user1@test.com", "password_hash" => "password1"}))

        assert %{"token" => token} = json_response(login_response, 200)

        create_task_response =
          conn
          |> put_req_header("content-type", "multipart/form-data")
          |> put_req_header("authorization", "Bearer #{token}")
          |> post(~p"/api/tasks/create", "{\"title\": \"Buy chocolate\", \"description\": \"give it to Adam\"}")

        assert json_response(create_task_response, 201)["task"]
    end

    test "POST /api/tasks/create when input is invalid", %{conn: conn} do
      login_response =
        conn
        |> post(~p"/api/user/login", Jason.encode!(%{"email" => "user1@test.com", "password_hash" => "password1"}))

      assert %{"token" => token} = json_response(login_response, 200)

      create_task_response =
        conn
        |> put_req_header("authorization", "Bearer #{token}")
        |> post(~p"/api/tasks/create", Jason.encode!(@invalid_attrs))

      assert json_response(create_task_response, 400)["errors"] != %{}
    end

    test "POST /api/tasks/create when no user is logged in", %{conn: conn} do
      create_task_response =
        conn
        |> put_req_header("authorization", "Bearer sometoken")
        |> post(~p"/api/tasks/create", Jason.encode!(@create_attrs))

      assert json_response(create_task_response, 401)
    end
  end

  describe "update" do
    test "POST /api/tasks/update/:id when id is valid", %{conn: conn} do
      login_response =
        conn
        |> post(~p"/api/user/login", Jason.encode!(%{"email" => "user1@test.com", "password_hash" => "password1"}))

      assert %{"token" => token} = json_response(login_response, 200)

      create_task_response =
        conn
        |> put_req_header("authorization", "Bearer #{token}")
        |> post(~p"/api/tasks/create", Jason.encode!(@create_attrs))

      assert %{"id" => id} = json_response(create_task_response, 201)["task"]
      Process.sleep(1000)

      update_task_response =
        conn
        |> put_req_header("authorization", "Bearer #{token}")
        |> put(~p"/api/tasks/update/#{id}", Jason.encode!(@update_attrs))

      assert %{"id" => ^id, "title" => "Get groceries from the market", "completed" => true} = json_response(update_task_response, 200)["task"]
    end

    test "POST /api/tasks/update/:id when id is invalid", %{conn: conn} do
      login_response =
        conn
        |> post(~p"/api/user/login", Jason.encode!(%{"email" => "user1@test.com", "password_hash" => "password1"}))

      assert %{"token" => token} = json_response(login_response, 200)

      update_task_response =
        conn
        |> put_req_header("authorization", "Bearer #{token}")
        |> put(~p"/api/tasks/update/567", Jason.encode!(@update_attrs))

      assert json_response(update_task_response, 404)["errors"] != %{}
    end

    test "POST /api/tasks/update/:id when input is invalid", %{conn: conn} do
      login_response =
        conn
        |> post(~p"/api/user/login", Jason.encode!(%{"email" => "user1@test.com", "password_hash" => "password1"}))

      assert %{"token" => token} = json_response(login_response, 200)

      update_task_response =
        conn
        |> put_req_header("authorization", "Bearer #{token}")
        |> put(~p"/api/tasks/update/567", Jason.encode!(@invalid_attrs))

      assert json_response(update_task_response, 400)["errors"] != %{}
    end

    test "POST /api/tasks/update/:id when no user is logged in", %{conn: conn} do
      update_task_response =
        conn
        |> put_req_header("authorization", "Bearer sometoken")
        |> put(~p"/api/tasks/update/567", Jason.encode!(@update_attrs))

      assert json_response(update_task_response, 401)["errors"] != %{}
    end
  end

  describe "delete" do
    test "DELETE /api/tasks/delete/:id when id is valid", %{conn: conn} do
        login_response =
          conn
          |> post(~p"/api/user/login", Jason.encode!(%{"email" => "user1@test.com", "password_hash" => "password1"}))

        assert %{"token" => token} = json_response(login_response, 200)

        create_task_response =
          conn
          |> put_req_header("authorization", "Bearer #{token}")
          |> post(~p"/api/tasks/create", Jason.encode!(@create_attrs))

        assert %{"id" => id} = json_response(create_task_response, 201)["task"]
        Process.sleep(1000)

        delete_task_response =
          conn
          |> put_req_header("authorization", "Bearer #{token}")
          |> delete(~p"/api/tasks/delete/#{id}")

        assert response(delete_task_response, 204)
    end

    test "DELETE /api/tasks/delete/:id when id is invalid", %{conn: conn} do
      login_response =
        conn
        |> post(~p"/api/user/login", Jason.encode!(%{"email" => "user1@test.com", "password_hash" => "password1"}))

      assert %{"token" => token} = json_response(login_response, 200)

      delete_task_response =
        conn
        |> put_req_header("authorization", "Bearer #{token}")
        |> delete(~p"/api/tasks/delete/764")

      assert json_response(delete_task_response, 404)["errors"] != %{}
    end

    test "DELETE /api/tasks/delete/:id when no user is logged in", %{conn: conn} do
      delete_task_response =
        conn
        |> put_req_header("authorization", "Bearer sometoken")
        |> delete(~p"/api/tasks/delete/764")

      assert json_response(delete_task_response, 401)
    end
  end

  describe "search" do
    test "POST /api/tasks/search with valid search query and results", %{conn: conn} do
      login_response =
        conn
        |> post(~p"/api/user/login", Jason.encode!(%{"email" => "user1@test.com", "password_hash" => "password1"}))

      assert %{"token" => token} = json_response(login_response, 200)

      create_task_response =
        conn
        |> put_req_header("authorization", "Bearer #{token}")
        |> post(~p"/api/tasks/create", Jason.encode!(@create_attrs))

      assert json_response(create_task_response, 201)["task"]
      Process.sleep(1000)

      test_cases = [
        "{\"search\": \"get\"}",
        "{\"search\": \"apple\"}"
      ]

      Enum.each(test_cases, fn search_query ->
        search_response = post(conn, "/api/tasks/search", search_query)

        assert json_response(search_response, 200)["tasks"] != []
      end)

    end

    test "POST /api/tasks/search with valid search query and no results", %{conn: conn} do
      test_cases = [
        "{\"search\": \"gterqaw\"}",
        "{\"search\": \"...........\"}",
        "{\"search\": \"??@#!\"}"
      ]

      Enum.each(test_cases, fn search_query ->
        conn =
          conn
          |> post("/api/tasks/search", search_query)

        assert json_response(conn, 404)["errors"] != %{}
      end)
    end

    test "POST /api/tasks/search with invalid search query", %{conn: conn} do
      test_cases = [
        "{}",
        "{vrewarewv}",
        "{\"something\":}",
        "{\"parmeter\": 5432}",
        "{\"match\": {false}}"
      ]

      Enum.each(test_cases, fn search_query ->
        conn =
          conn
          |> post("/api/tasks/search", search_query)

          assert json_response(conn, 400) != %{}
      end)
    end
  end
end
