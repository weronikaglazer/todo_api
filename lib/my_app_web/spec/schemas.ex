defmodule MyAppWeb.Schemas do
  require OpenApiSpex
  alias OpenApiSpex.Schema


  # Task Schemas

  defmodule Task do
    OpenApiSpex.schema(%{
      title: "Task",
      description: "A task in the app",
      type: :object,
      properties: %{
        id: %Schema{type: :integer, description: "Task ID", minimum: 1},
        title: %Schema{type: :string, description: "Task title", pattern: ~r/[a-zA-Z0-9]+/},
        description: %Schema{type: :string, description: "Task description", pattern: ~r/[a-zA-Z0-9]+/},
        completed: %Schema{type: :boolean, description: "Is the task completed?"},
        user_id: %Schema{type: :integer, description: "User ID", minimum: 1},
        files: %Schema{description: "The list of files", type: :array, items: MyAppWeb.Schemas.File}
      },
      required: [:id, :title, :description, :completed, :user_id],
      example: %{
        "id" => 123,
        "title" => "Get groceries",
        "description" => "List: bananas, apples, bread",
        "completed" => false,
        "files" => [
          %{
            "id" => 11,
            "name" => "image.jpg",
            "path" => "priv/static/uploads/user1/task123/image.jpg",
            "task_id" => 123
          },
          %{
            "id" => 12,
            "name" => "image2.jpg",
            "path" => "priv/static/uploads/user1/task123/image2.jpg",
            "task_id" => 123
          }
        ],
        "user_id" => 1
      }
    })
  end

  defmodule TaskResponse do

    OpenApiSpex.schema(%{
      title: "CreatedUpdatedTaskResponse",
      description: "Response schema for single created/updated task",
      type: :object,
      properties: %{
        task: Task
      },
      example: %{
        "task" => %{
          "id" => 123,
          "title" => "Get groceries",
          "description" => "List: apples, bread, milk",
          "completed" => false,
          "files" => [
            %{
              "id" => 11,
              "name" => "image.jpg",
              "path" => "priv/static/uploads/user1/task123/image.jpg",
              "task_id" => 123
            },
            %{
              "id" => 12,
              "name" => "image2.jpg",
              "path" => "priv/static/uploads/user1/task123/image2.jpg",
              "task_id" => 123
            }
          ],
          "user_id" => 1
        }
      }
    })
  end

  defmodule TasksResponse do
    OpenApiSpex.schema(%{
      title: "TasksResponse",
      description: "Response schema for multiple tasks",
      type: :object,
      properties: %{
        tasks: %Schema{description: "The list of tasks", type: :array, items: Task}
      },
      example: %{
        "tasks" => [
          %{
            "id" => 123,
            "title" => "Get groceries",
            "description" => "List: apples, bananas, bread",
            "completed" => false,
            "user_id" => 2
          },
          %{
            "id" => 124,
            "title" => "Make dinner",
            "description" => "Spaghetti and corn soup",
            "completed" => true,
            "user_id" => 4
          }
        ]
      }
    })
  end

  defmodule TaskCreateParams do
    OpenApiSpex.schema(%{
      title: "TaskCreateParams",
      description: "Parameters for creating a task",
      type: :object,
      properties: %{
        title: %Schema{type: :string, description: "Task title", pattern: ~r/[a-zA-Z0-9]+/},
        description: %Schema{type: :string, description: "Task description", pattern: ~r/[a-zA-Z0-9]+/},
        completed: %Schema{type: :boolean, description: "Is the task completed?"}
      },
      required: [:title],
      example: %{
        "title" => "Get groceries",
        "description" => "List: apples, bread, milk",
        "completed" => false
      }
    })
  end

  defmodule TaskCreateReqBody do
    OpenApiSpex.schema(
      %{
        title: "TaskCreateReqBody",
        description: "Request body for creating a task",
        type: :object,
        properties: %{
          task: TaskCreateParams,
          file: %Schema{type: :binary, description: "File"}
        },
        required: [:task]
      }
    )
  end

  defmodule TaskUpdateReqBody do
    OpenApiSpex.schema(%{
      title: "TaskUpdateReqBody",
      description: "Request body for updating a task",
      type: :object,
      properties: %{
        title: %Schema{type: :string, description: "Task title", pattern: ~r/[a-zA-Z0-9]+/},
        description: %Schema{type: :string, description: "Task description", pattern: ~r/[a-zA-Z0-9]+/},
        completed: %Schema{type: :boolean, description: "Is the task completed?"}
      },
      example: %{
        "title" => "Updated task title",
        "description" => "New description",
        "completed" => true
      }
    })
  end

  defmodule TasksSearchReqBody do
    OpenApiSpex.schema(%{
      title: "TasksSearchReqBody",
      description: "Request body for performing search on all tasks",
      type: :object,
      properties: %{
        search: %Schema{type: :string, description: "Search string input", pattern: ~r/[a-zA-Z0-9]+/},
      },
      required: [:search],
      example: %{
        "search" => "get"
      }
    })
  end

  defmodule TasksSearchResponseBody do
    OpenApiSpex.schema(%{
      title: "TasksSearchResponseBody",
      description: "Response schema for searching through tasks",
      type: :object,
      properties: %{
        tasks: %Schema{description: "The list of tasks", type: :array, items: Task}
      },
      example: %{
        "tasks" => [
          %{
            "elastic_search_id" => 55,
            "title" => "Get groceries",
            "description" => "List: apples, bananas, bread",
            "completed" => false
          },
          %{
            "elastic_search_id" => 44,
            "title" => "Get dinner",
            "description" => "Spaghetti and corn soup",
            "completed" => true
          }
        ]
      }
    })
  end


  # File Schemas

  defmodule File do
    OpenApiSpex.schema(%{
      title: "File",
      description: "A file in the app",
      type: :object,
      properties: %{
        id: %Schema{type: :integer, description: "File ID", minimum: 1},
        name: %Schema{type: :string, description: "File name", pattern: ~r/[a-zA-Z0-9]+.[a-z]/},
        path: %Schema{type: :string, description: "File path"},
        task_id: %Schema{type: :integer, description: "Task ID", minimum: 1}
      },
      required: [:id, :name, :path, :task_id],
      example: %{
        "id" => 123,
        "name" => "photo.jpg",
        "path" => "priv/static/uploads/user10/task1324/photo.jpg",
        "task_id" => 1324
      }
    })
  end

  defmodule FileRenameReqBody do
    OpenApiSpex.schema(%{
      title: "FileRenameReqBody",
      description: "Request body for renaming a file",
      type: :object,
      properties: %{
        name: %Schema{type: :string, description: "File name", pattern: ~r/[a-zA-Z0-9]+/}
      },
      required: [:name],
      example: %{
        "name" => "image"
      }
    })
  end

  defmodule FileUploadReqBody do
    OpenApiSpex.schema(%{
      title: "FileUploadReqBody",
      description: "Request body for uploading a file for existing task",
      type: :object,
      properties: %{
        file: %Schema{type: :binary, description: "File"}
      }
    })
  end

  defmodule FileResponse do
    OpenApiSpex.schema(%{
      title: "FileResponse",
      description: "Response schema for single file",
      type: :object,
      properties: %{
        file: File
      },
      example: %{
        "file" => %{
          "id" => 123,
          "name" => "image.jpg",
          "path" => "priv/static/uploads/user10/task1234/image.jpg",
          "task_id" => 1234
        }
      }
    })
  end

  defmodule FilesResponse do
    OpenApiSpex.schema(%{
      title: "FilesResponse",
      description: "Response schema for multiple files",
      type: :object,
      properties: %{
        files: %Schema{description: "The list of files", type: :array, items: File}
      },
      example: %{
        "files" => [
          %{
            "id" => 123,
            "name" => "image.jpg",
            "path" => "priv/static/uploads/user10/task1234/image.jpg",
            "task_id" => 1234
          },
          %{
            "id" => 124,
            "name" => "image2.jpg",
            "path" => "priv/static/uploads/user10/task1234/image2.jpg",
            "task_id" => 1234
          }
        ]
      }
    })
  end

  defmodule FileDownloadResponse do
    OpenApiSpex.schema(%{
      title: "FileDownloadResponse",
      description: "Response schema for downloading a file",
      type: :file
    })
  end

  # User Schemas

  defmodule User do
    OpenApiSpex.schema(%{
      title: "User",
      description: "A user in the app",
      type: :object,
      properties: %{
        id: %Schema{type: :integer, description: "User ID", minimum: 1},
        email: %Schema{type: :string, description: "User email", pattern: ~r/^[a-z0-9]{3,9}@[a-z]{3,6}\.com$/},
        mobile: %Schema{type: :string, description: "User mobile", pattern: ~r/[0-9]{9}/}},
        task_ids: %Schema{description: "IDs of tasks assigned to the user", type: :array}
      },
      required: [:id, :email, :mobile],
      example: %{
        "id" => 1,
        "email" => "user1@test.com",
        "mobile" => "987654321",
        "task_ids" => [123,124]
      }
    )
  end

  defmodule UserWithToken do
    OpenApiSpex.schema(%{
      title: "UserWithToken",
      description: "A user in the app with it's assigned token",
      type: :object,
      properties: %{
        id: %Schema{type: :integer, description: "User ID", minimum: 1},
        token: %Schema{type: :string, description: "Generated Guardian token"},
        email: %Schema{type: :string, description: "User email", pattern: ~r/^[a-z0-9]{3,9}@[a-z]{3,6}\.com$/},
        mobile: %Schema{type: :string, description: "User mobile", pattern: ~r/[0-9]{9}/},
        task_ids: %Schema{description: "Task IDs assigned to the user", type: :array}
      },
      example: %{
        "id" => 1,
        "token" => "tokenstring",
        "email" => "user1@test.com",
        "mobile" => "987654321",
        "task_ids" => [1,4,43]
      }
    })
  end

  defmodule UserRegisterParams do
    OpenApiSpex.schema(%{
      title: "UserRegisterParams",
      description: "Parameters required when registering a new user",
      type: :object,
      properties: %{
        email: %Schema{type: :string, description: "User email", pattern: ~r/^[a-z0-9]{3,9}@[a-z]{3,6}\.com$/},
        mobile: %Schema{type: :string, description: "User mobile", pattern: ~r/[0-9]{9}/},
        password_hash: %Schema{type: :string, description: "User password", pattern: ~r/[A-Za-z0-9+!#@$]{8,12}/}
      },
      required: [:email, :mobile, :password_hash],
      example: %{
        "email" => "user1@test.com",
        "mobile" => "987654321",
        "password_hash" => "password123"
      }
    })
  end

  defmodule UserRegisterReqBody do
    OpenApiSpex.schema(%{
      title: "UserResgisterReqBody",
      description: "Request body for registering a new user",
      type: :object,
      properties: %{
        user: UserRegisterParams}
      },
      required: [:user],
      example: %{
        "user" => %{
          "mobile" => "878323212",
          "email" => "email@test.com",
          "password_hash" => "password21"
      }
      }
    )
  end

  defmodule UserLoginReqBody do
    OpenApiSpex.schema(%{
      title: "UserLoginReqBody",
      description: "Request body for logging into a user account",
      type: :object,
      properties: %{
        credential: %Schema{type: :string, description: "Could be either mobile or email"},
        password_hash: %Schema{type: :string, description: "User password", pattern: ~r/[A-Za-z0-9+!#@$]{8,12}/}
      },
      required: [:credential, :password_hash],
      example: %{
          "email" => "email@test.com",
          "password_hash" => "password21"
      }
    })
  end

  defmodule UserUpdateParams do
    OpenApiSpex.schema(%{
      title: "UserUpdateParams",
      description: "Parameters for updating user's data",
      type: :object,
      properties: %{
        email: %Schema{type: :string, description: "User email", pattern: ~r/^[a-z0-9]{3,9}@[a-z]{3,6}\.com$/},
        mobile: %Schema{type: :string, description: "User mobile", pattern: ~r/[0-9]{9}/},
        password_hash: %Schema{type: :string, description: "User password", pattern: ~r/[A-Za-z0-9+!#@$]{8,12}/}
      },
      required: [],
      example: %{
        "email" => "updated@email.com",
        "mobile" => "987654321",
        "password_hash" => "updatedpassword"
      }
    })
  end

  defmodule UserUpdateReqBody do
    OpenApiSpex.schema(%{
      title: "UserUpdateReqBody",
      description: "Request body for updating user's data",
      type: :object,
      properties: %{
        user: UserUpdateParams}
      },
      required: [:user],
      example: %{
        "user" => %{
          "mobile" => "878323212",
          "email" => "updated@email.com",
          "password_hash" => "updatedpassword"
        }
      }
    )
  end

  defmodule UserDeleteParams do
    OpenApiSpex.schema(%{
      title: "UserDeleteParams",
      description: "Parameters for deleting a user",
      type: :object,
      properties: %{
        password: %Schema{type: :string, description: "User password", pattern: ~r/[A-Za-z0-9+!#@$]{8,12}/}
      },
      required: [:password],
      example: %{
        "password" => "validpassword1234"
      }
    })
  end

  defmodule UserDeleteReqBody do
    OpenApiSpex.schema(%{
      title: "UserDeleteReqBody",
      description: "Request body for deleting a user",
      type: :object,
      properties: %{
        user: UserDeleteParams}
      },
      required: [:user],
      example: %{
        "user" => %{
          "password" => "validpassword123"
        }
      }
    )
  end

  defmodule UsersResponse do
    OpenApiSpex.schema(%{
      title: "UsersResponse",
      description: "Response schema for multiple users",
      type: :object,
      properties: %{
        users: %Schema{description: "The task details", type: :array, items: User}
      },
      example: %{
        "users" => [
          %{
            "id" => 1,
            "email" => "user1@test.com",
            "mobile" => "987654321",
            "task_ids" => [2,56,234]
          },
          %{
            "id" => 2,
            "email" => "user2@test.com",
            "mobile" => "111222333",
            "task_ids" => [12,46,216]
          }
        ]
      }
    })
  end

  defmodule UserResponse do
    OpenApiSpex.schema(%{
      title: "UserResponse",
      description: "Response schema for one user",
      type: :object,
      properties: %{
        data: User
      },
      example: %{
        "data" =>
          %{
            "id" => 1,
            "email" => "user1@test.com",
            "task_ids" => [123,124],
            "mobile" => "987654321"
          }
      }
    })
  end


  # Profile Schemas

  defmodule Profile do
    OpenApiSpex.schema(%{
      title: "Profile",
      description: "A profile in the app",
      type: :object,
      properties: %{
        id: %Schema{type: :integer, description: "Profile ID", minimum: 1},
        name: %Schema{type: :string, description: "Profile name"},
      },
      required: [:id, :name, :user_id],
      example: %{
        "id" => 1,
        "name" => "johnsmith123",
        "user_id" => 1
      }
    })
  end

  defmodule ProfileResponse do
    OpenApiSpex.schema(%{
      title: "ProfileResponse",
      description: "Response schema for one profile",
      type: :object,
      properties: %{
        data: Profile
      },
      example: %{
        "data" =>
          %{
            "id" => 1,
            "name" => "johnsmith123",
            "user_id" => 1
          }
      }
    })
  end

  defmodule ProfileCreateOrUpdateParams do
    OpenApiSpex.schema(%{
      title: "ProfileCreateParams",
      description: "Parameters required when creating a profile",
      type: :object,
      properties: %{
        name: %Schema{type: :string, description: "Profile name"}
      },
      required: [:name],
      example: %{
        "name" => "johnsmith123"
      }
    })
  end

  defmodule ProfileCreateOrUpdateReqBody do
    OpenApiSpex.schema(%{
      title: "ProfileCreateReqBody",
      description: "Request body for creating a profile",
      type: :object,
      properties: %{
        profile: ProfileCreateOrUpdateParams}
      },
      required: [:profile],
      example: %{
        "profile" => %{
          "name" => "johnsmith123"
        }
      }
    )
  end



  # Error Schemas

  defmodule NoContent do
    require OpenApiSpex

    OpenApiSpex.schema(%{
      title: "NoContent",
      description: "Response schema for deleting a task",
      type: :object,
      properties: %{},
      example: %{}
    })
  end

  defmodule NotFound do
    require OpenApiSpex

    OpenApiSpex.schema(%{
      title: "NotFound",
      description: "Response schema for not found error",
      type: :object,
      properties: %{
        errors: %Schema{type: :string, description: "Not Found message"}
      },
      example: %{
        "errors" => %{
          "detail" => "Not Found"
        }
      }
    })
  end

  defmodule BadRequest do
    require OpenApiSpex

    OpenApiSpex.schema(%{
      title: "BadRequest",
      description: "Response schema for bad request error",
      type: :object,
      properties: %{
        errors: %Schema{type: :string, description: "Bad Request message"}
      },
      example: %{
        "errors" => %{
          "detail" => "Bad Request"
        }
      }
    })
  end

  defmodule InternalServerError do
    require OpenApiSpex

    OpenApiSpex.schema(%{
      title: "InternalServerError",
      description: "Response schema for internal server error",
      type: :object,
      properties: %{
        errors: %Schema{type: :string, description: "Internal Server Error message"}
      },
      example: %{
        "errors" => %{
          "detail" => "Internal Server Error"
        }
      }
    })
  end

  defmodule Unauthorized do
    OpenApiSpex.schema(%{
      title: "Unauthorized",
      description: "Response schema for unauthorized error",
      type: :object,
      properties: %{
        errors: %Schema{type: :string, description: "Unauthorized error message"}
      },
      example: %{
        "errors" => "unauthenticated"
      }
    })
  end

  defmodule Conflict do
    OpenApiSpex.schema(%{
      title: "Conflict",
      description: "Response schema for conflict error",
      type: :object,
      properties: %{
        errors: %Schema{type: :string, description: "Conflict error message"}
      },
      example: %{
        "errors" => %{
          "detail" => "This resource already exists"
        }
      }
    })
  end
end
