defmodule PhantomChat.Schema.MessageTest do
  use ExUnit.Case
  use PhantomChat.DataCase
  alias PhantomChat.Schema.{Message, ChatRoom, User}
  alias PhantomChat.Repo
  import Ecto.Query

  test "schema fields" do
    assert Message.__schema__(:fields) == [
             :id,
             :content,
             :inserted_at,
             :updated_at,
             :user_id,
             :chatroom_id
           ]
  end

  test "create chatroom" do
    now = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)

    user_id = create_user(now)
    chatroom_id = create_chatroom(now)

    {:ok, %Message{id: id, content: message_content}} =
      Repo.insert(%Message{
        content: "This is new message from XYZ",
        inserted_at: now,
        updated_at: now,
        user_id: user_id,
        chatroom_id: chatroom_id
      })

    %Message{id: get_id, content: get_message_content} =
      from(x in Message) |> Repo.all() |> List.last()

    assert id == get_id
    assert message_content == get_message_content
  end

  defp create_user(now) do
    {:ok, %User{id: user_id}} =
      Repo.insert(%User{
        name: "nick",
        inserted_at: now,
        updated_at: now
      })

    user_id
  end

  defp create_chatroom(now) do
    {:ok, %ChatRoom{id: chatroom_id}} =
      Repo.insert(%ChatRoom{
        room_name: "room_random5",
        type: :public,
        inserted_at: now,
        updated_at: now,
        msg_duration_in_minutes: 5
      })

    chatroom_id
  end
end
