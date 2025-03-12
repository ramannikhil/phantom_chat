defmodule Helper.Service.User do
  alias PhantomChat.Repo
  alias PhantomChat.Schema.User

  def create_user(user_name) do
    now = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)

    Repo.insert(%User{
      name: user_name,
      inserted_at: now,
      updated_at: now
    })
  end

  def update_user(user_id) do
    now = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)

    Repo.get(User, user_id) |> Ecto.Changeset.change(updated_at: now) |> Repo.update()
  end
end
