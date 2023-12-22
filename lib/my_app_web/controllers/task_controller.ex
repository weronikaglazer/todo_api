defmodule MyAppWeb.TaskController do
  use MyAppWeb, :controller
  use OpenApiSpex.ControllerSpecs
  alias MyAppWeb.{Schemas}
  alias MyApp.{ElasticsearchService, Users, Tasks, Files}

  action_fallback MyAppWeb.FallbackController
  tags ["Task Controller"]


  operation :index,
    summary: "Lists all tasks assigned to the user",
    request_body: {},
    responses: %{
      200 => {"Tasks listed", "application/json", Schemas.TasksResponse},
      404 => {"Profile or tasks not found", "application/json", Schemas.NotFound},
      401 => {"No user is logged in", "application/json", Schemas.Unauthorized}
    },
    security: [%{"authorization" => []}]

  def index(conn, _params) do
    user = Guardian.Plug.current_resource(conn)
    tasks = Tasks.get_tasks_by_user_id(user.id)

    if tasks != [] do
      conn
      |> put_status(:ok)
      |> render(:index, tasks: tasks)
    else
      {:error, :not_found}
    end
  end


  operation :show,
    summary: "Shows a task by ID",
    parameters: [
      id: [
        in: :path,
        description: "Task ID",
        type: :integer,
        example: 123
      ]
    ],
    request_body: {},
    responses: %{
      200 => {"Task rendered", "application/json", Schemas.TaskResponse},
      404 => {"Profile or task not found", "application/json", Schemas.NotFound},
      401 => {"No user is logged in", "application/json", Schemas.Unauthorized}
    },
    security: [%{"authorization" => []}]
  def show(conn, %{"id" => id}) do
    user = Guardian.Plug.current_resource(conn)
    task = Tasks.get_task(id)

    if task != nil and user.id == task.user_id do
      files = Files.get_files_by_task_id(task.id)
      render(conn, :show_task, task: task, files: files)
    else
      {:error, :not_found}
    end
  end


  operation :create,
    summary: "Creates a task. Task can be created with or without files. Multiple files can be passed and only unique files will be uploaded successfully.",
    request_body: {"Task params", "multipart/form-data", Schemas.TaskCreateReqBody},
    responses: %{
      200 => {"Task created", "application/json", Schemas.TaskResponse},
      400 => {"Invalid request body", "application/json", Schemas.BadRequest},
      401 => {"No user is logged in", "application/json", Schemas.Unauthorized}
    },
    security: [%{"authorization" => []}]

  def create(conn, params) do
    user = Guardian.Plug.current_resource(conn)

    if Map.has_key?(params, "file") do
      with {:ok, decoded_params} <- Jason.decode(params["task"]),
          {:ok, task_params} <- validate_task_params(decoded_params) do

          files = Map.drop(params, ["task"])

          with {:ok, created_task} <- create_task_with_files(task_params, files, user) do
            conn
            |> put_status(:created)
            |> render(:show_task, task: created_task, files: created_task.files)
          end
      end
    else
      with {:ok, decoded_params} <- Jason.decode(params["task"]),
          {:ok, task_params} <- validate_task_params(decoded_params) do
          task_params = Map.put(task_params, "id", :rand.uniform(99999))
          with {:ok, created_task} <- create_task(task_params, user) do
            conn
            |> put_status(:created)
            |> render(:show_task, task: created_task, files: [])
          end
      end
    end
  end

  defp create_task_with_files(task_params, files, user) do
    uploaded_unique_files =
      files
      |> Enum.uniq_by(fn {_key, file} -> file.filename end)
      |> Enum.map(fn {_key, file} -> file end)

    task_id = :rand.uniform(99999)
    path = "priv/static/uploads/user#{user.id}/task#{task_id}"

    files_params_map = Enum.map(uploaded_unique_files, fn file ->
      %{
        "name" => file.filename,
        "path" => "#{path}/#{file.filename}",
        "task_id" => task_id
      }
    end)

    task_and_files_params = Map.put(task_params, "id", task_id) |> Map.put("files", files_params_map)

    with {:ok, created_task} <- create_task(task_and_files_params, user),
          :ok <- File.mkdir_p(path) do

      Enum.each(uploaded_unique_files, fn file ->
        File.cp(file.path, "#{path}/#{file.filename}")
      end)

      {:ok, created_task}
    end
  end

  defp create_task(task_params, user) do
    with  {:ok, created_task} <- Tasks.create_task(user, task_params),
          {:ok, _response} <- ElasticsearchService.put_task(%MyApp.Task{
            id: created_task.id,
            title: created_task.title,
            description: created_task.description || "",
            completed: created_task.completed || false,
            user_id: created_task.user_id
          }),
          {:ok, _user} <- Users.update_user(user, %{task_ids: user.task_ids ++ [created_task.id]}) do
      {:ok, created_task}
    end
  end


  operation :update,
    summary: "Updates a task by ID",
    parameters: [
      id: [
        in: :path,
        description: "Task ID",
        type: :integer,
        example: 123
      ]
    ],
    request_body: {"Update task request body", "application/json", Schemas.TaskUpdateReqBody},
    responses: %{
      200 => {"Task updated properly", "application/json", Schemas.TaskResponse},
      400 => {"Wrong request body", "application/json", Schemas.BadRequest},
      404 => {"Profile or task not found", "application/json", Schemas.NotFound},
      401 => {"No user is logged in", "application/json", Schemas.Unauthorized}
    },
    security: [%{"authorization" => []}]
  def update(conn, %{"id" => id}) do
    user = Guardian.Plug.current_resource(conn)
    task_params = conn.body_params

    case validate_task_params(task_params) do
      {:ok, task_params} ->
        task = Tasks.get_task(id)
        files = Files.get_files_by_task_id(task.id) || []

        if task != nil and user.id == task.user_id do
          {:ok, [task_from_elastic_search | _]} = ElasticsearchService.search(%{"query" => %{"match" => %{"id" => task.id}}})

          with  {:ok, updated_task} <- Tasks.update_task(task, task_params),
                :ok <- ElasticsearchService.update_task(task_from_elastic_search, task_params) do
            conn
            |> put_status(:ok)
            |> render(:show_task, task: updated_task, files: files)
          end
        else
          {:error, :not_found}
        end
      {:error, _reason} -> {:error, :bad_request}
    end
  end


  operation :delete,
    summary: "Deletes a task by ID",
    parameters: [
      id: [
        in: :path,
        description: "Task ID",
        type: :integer,
        example: 123
      ]
    ],
    request_body: {},
    responses: %{
      204 => {"Task deleted properly", "application/json", Schemas.NoContent},
      404 => {"Profile or task not found", "application/json", Schemas.NotFound},
      401 => {"No user is logged in", "application/json", Schemas.Unauthorized}
    },
    security: [%{"authorization" => []}]
  def delete(conn, %{"id" => id}) do
    user = Guardian.Plug.current_resource(conn)
    task = Tasks.get_task(id)

    if task != nil and user.id == task.user_id do
      updated_task_ids = user.task_ids -- [task.id]
      {:ok, [task_from_elastic_search | _]} = ElasticsearchService.search(%{"query" => %{"match" => %{"id" => task.id}}})

      with  {:ok, _} <- Tasks.delete_task(task),
            {:ok, _} <- File.rm_rf("priv/static/uploads/user#{user.id}/task#{task.id}"),
            :ok <- ElasticsearchService.delete_task(task_from_elastic_search),
            {:ok, _} <- Users.update_user(user, %{task_ids: updated_task_ids}) do

          send_resp(conn, :no_content, "")
      end
    else
      {:error, :not_found}
    end
  end



  operation :search,
    summary: "Performs a search on all tasks",
    request_body: {"Search through tasks request body", "application/json", Schemas.TasksSearchReqBody},
    responses: %{
      200 => {"Tasks rendered", "application/json", Schemas.TasksSearchResponseBody},
      404 => {"No results", "application/json", Schemas.NotFound},
      400 => {"Invalid request body", "application/json", Schemas.BadRequest}
    }
  def search(conn, search_params) do
    if Map.has_key?(search_params, "search") and is_binary(search_params["search"]) do
      query = %{
        "query" => %{
          "simple_query_string" => %{
            "query" => "*#{search_params["search"]}*",
            "fields" => ["title", "description"],
            "default_operator" => "AND",
            "analyze_wildcard" => true
          }
        }
      }

      case ElasticsearchService.search(query) do
        {:error, _reason} -> {:error, :bad_request}
        {:ok, []} -> {:error, :not_found}

        {:ok, tasks} ->
          conn
          |> put_status(:ok)
          |> render(:index_search, tasks: tasks)
      end
    else
      {:error, :bad_request}
    end
  end



  defp validate_task_params(task_params) do
    available_params = ["title", "description", "completed"]

    params_valid? = Enum.all?(Map.keys(task_params), &(&1 in available_params))
    if params_valid? do
      {:ok, task_params}
    else
      {:error, :bad_request}
    end
  end
end
