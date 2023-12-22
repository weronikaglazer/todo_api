defmodule MyAppWeb.FileController do
  use MyAppWeb, :controller
  use OpenApiSpex.ControllerSpecs
  alias MyAppWeb.Schemas.FileUploadReqBody
  alias MyAppWeb.{Schemas}
  alias MyApp.{Tasks, Files}

  action_fallback MyAppWeb.FallbackController
  tags ["File Controller"]
  security [%{"authorization" => []}]


  operation :upload,
    summary: "Uploads files to the given task. Multiple files can be passed and only unique files will be uploaded successfully.",
    request_body: {"Files to be uploaded", "multipart/form-data", FileUploadReqBody},
    parameters: [
      id: [
        in: :path,
        description: "Task ID",
        type: :integer,
        example: 123
      ]
    ],
    responses: %{
      200 => {"Files uploaded", "application/json", Schemas.FilesResponse},
      404 => {"Task not found", "application/json", Schemas.NotFound},
      401 => {"No user is logged in", "application/json", Schemas.Unauthorized},
      409 => {"One of the files is already assigned to given task", "application/json", Schemas.Conflict}
    }
  def upload(conn, params) do
    user = Guardian.Plug.current_resource(conn)
    task = Tasks.get_task(params["id"])

    if task != nil and user.id == task.user_id do
      files = Map.drop(params, ["id"])
      path = "priv/static/uploads/user#{user.id}/task#{task.id}"
      if File.exists?(path) == false, do: File.mkdir_p(path)

      uploaded_unique_files =
        files
        |> Enum.uniq_by(fn {_key, file} -> file.filename end)
        |> Enum.map(fn {_key, file} -> file end)

      files_params_map = Enum.map(uploaded_unique_files, fn file ->
        %{
          name: file.filename,
          path: "#{path}/#{file.filename}",
          task_id: task.id
        }
      end)

      with :ok <- Files.create_files(files_params_map),
          :ok <- Enum.each(uploaded_unique_files, fn file ->
            File.cp(file.path, "#{path}/#{file.filename}") end) do

            files = Files.get_files_by_task_id(task.id)
            render(conn, :index, files: files)
      end
    end
  end

  operation :rename,
    summary: "Renames the file",
    request_body: {"File params", "application/json", Schemas.FileRenameReqBody},
    parameters: [
      id: [
        in: :path,
        description: "File ID",
        type: :integer,
        example: 123
      ]
    ],
    responses: %{
      200 => {"File renamed", "application/json", Schemas.FileResponse},
      404 => {"File or task not found", "application/json", Schemas.NotFound},
      401 => {"No user is logged in", "application/json", Schemas.Unauthorized}
    }
  def rename(conn, params) do
    if Map.has_key?(params, "name") do
      user = Guardian.Plug.current_resource(conn)

      with {:ok, {_task, file}} <- validate_access(user, params["task_id"], params["file_id"]) do
        extension = Path.extname(file.path)
        new_filename = params["name"] <> extension
        new_path = "#{Path.dirname(file.path)}/#{new_filename}"

        with {:ok, updated_file} <- Files.update_file(file, %{name: new_filename, path: new_path}),
              :ok <- File.rename(file.path, new_path) do
          render(conn, :show_file, file: updated_file)
        end
      end
    else
      {:error, :bad_request}
    end
  end

  operation :download,
    summary: "Downloads the file",
    request_body: {},
    parameters: [
      task_id: [
        in: :path,
        description: "Task ID",
        type: :integer,
        example: 123
      ],
      file_id: [
        in: :path,
        description: "File ID",
        type: :integer,
        example: 123
      ]
    ],
    responses: %{
      200 => {"File downloaded", "application/jpg", Schemas.FileDownloadResponse},
      404 => {"File or task not found", "application/json", Schemas.NotFound},
      401 => {"No user is logged in", "application/json", Schemas.Unauthorized}
    }
  def download(conn, %{"task_id" => task_id, "file_id" => file_id}) do
    user = Guardian.Plug.current_resource(conn)

    with {:ok, {_task, file}} <- validate_access(user, task_id, file_id),
          {:ok, file_contents} <- File.read(file.path) do
        send_download(conn, {:binary, file_contents}, filename: file.name)
    end
  end

  operation :delete,
    summary: "Deletes the file",
    request_body: {},
    parameters: [
      task_id: [
        in: :path,
        description: "Task ID",
        type: :integer,
        example: 123
      ],
      file_id: [
        in: :path,
        description: "File ID",
        type: :integer,
        example: 123
      ]
    ],
    responses: %{
      204 => {"File deleted", "application/json", Schemas.NoContent},
      404 => {"File or task not found", "application/json", Schemas.NotFound},
      401 => {"No user is logged in", "application/json", Schemas.Unauthorized}
    }
  def delete(conn, %{"task_id" => task_id, "file_id" => file_id}) do
    user = Guardian.Plug.current_resource(conn)

    with {:ok, {_task, file}} <- validate_access(user, task_id, file_id),
          :ok <- File.rm(file.path),
          {:ok, _removed_file} <- Files.delete_file(file) do
          send_resp(conn, :no_content, "")
    end
  end

  defp validate_access(user, task_id, file_id) do
    case {Tasks.get_task(task_id), Files.get_file(file_id)} do
      {task, file} when task.user_id == user.id and task.id == file.task_id -> {:ok, {task, file}}
      _ -> {:error, :not_found}
    end
  end
end
