defmodule PhantomChat.Schema.UserTest do
  use ExUnit.Case
  use PhantomChat.DataCase
  alias PhantomChat.Schema.User
  alias PhantomChat.Repo
  import Ecto.Query

  test "schema fields" do
    assert User.__schema__(:fields) == [:id, :name, :inserted_at, :updated_at]
  end

  test "create user" do
    now = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)

    {:ok, %User{id: id, name: user_name}} =
      Repo.insert(%User{
        name: "nick",
        inserted_at: now,
        updated_at: now
      })

    %User{id: get_id, name: get_user_name} = from(x in User) |> Repo.all() |> List.last()

    assert id == get_id
    assert user_name == get_user_name
  end
end
