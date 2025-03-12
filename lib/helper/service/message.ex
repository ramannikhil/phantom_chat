defmodule Helper.Service.Message do
  alias PhantomChat.Repo
  alias PhantomChat.Schema.Message

  def create_message(message, chatroom_id, user_id) do
    now = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)

    Repo.insert(%Message{
      content: message,
      inserted_at: now,
      updated_at: now,
      user_id: user_id,
      chatroom_id: chatroom_id
    })
  end
end
