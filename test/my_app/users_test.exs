defmodule MyApp.UsersTest do
  use MyApp.DataCase
  alias MyApp.{Users, Users.User}
  
  describe "users" do
    alias MyApp.Users.User

    import MyApp.UsersFixtures

    @invalid_attrs %{info: nil, mobile: nil, email: nil, password_hash: nil}

    test "list_users/0 returns all users" do
      user = user_fixture()
      assert Users.list_users() == [user]
    end

    test "get_user!/1 returns the user with given id" do
      user = user_fixture()
      assert Users.get_user!(user.id) == user
    end

    test "create_user/1 with valid data creates a user" do
      valid_attrs = %{info: %{}, mobile: "some mobile", email: "some email", password_hash: "some password_hash"}

      assert {:ok, %User{} = user} = Users.create_user(valid_attrs)
      assert user.info == %{}
      assert user.mobile == "some mobile"
      assert user.email == "some email"
      assert user.password_hash == "some password_hash"
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Users.create_user(@invalid_attrs)
    end

    test "update_user/2 with valid data updates the user" do
      user = user_fixture()
      update_attrs = %{info: %{}, mobile: "some updated mobile", email: "some updated email", password_hash: "some updated password_hash"}

      assert {:ok, %User{} = user} = Users.update_user(user, update_attrs)
      assert user.info == %{}
      assert user.mobile == "some updated mobile"
      assert user.email == "some updated email"
      assert user.password_hash == "some updated password_hash"
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Users.update_user(user, @invalid_attrs)
      assert user == Users.get_user!(user.id)
    end

    test "delete_user/1 deletes the user" do
      user = user_fixture()
      assert {:ok, %User{}} = Users.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Users.get_user!(user.id) end
    end

    test "change_user/1 returns a user changeset" do
      user = user_fixture()
      assert %Ecto.Changeset{} = Users.change_user(user)
    end
  end
end
