defmodule Helper.Service.ChatRoom do
  alias PhantomChat.Schema.ChatRoom
  alias PhantomChat.Repo

  def create_chat_room(room_name, message_duration) do
    now = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)

    Repo.insert(%ChatRoom{
      room_name: "room_" <> room_name,
      type: :public,
      updated_at: now,
      inserted_at: now,
      msg_duration_in_minutes: message_duration
    })
  end

  def update_chat_room(chatroom_id) do
    now = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)

    Repo.get(ChatRoom, chatroom_id) |> Ecto.Changeset.change(updated_at: now) |> Repo.update()
  end
end
