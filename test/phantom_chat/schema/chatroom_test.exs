defmodule PhantomChat.Schema.ChatroomTest do
  use ExUnit.Case, async: false
  use PhantomChat.DataCase, async: false
  alias PhantomChat.Schema.ChatRoom
  alias PhantomChat.Repo
  import Ecto.Query

  test "schema fields" do
    assert ChatRoom.__schema__(:fields) == [
             :id,
             :room_name,
             :type,
             :passcode,
             :inserted_at,
             :updated_at,
             :msg_duration_in_minutes
           ]
  end

  test "create chatroom" do
    now = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)

    {:ok, %ChatRoom{id: id, room_name: room_name}} =
      Repo.insert(%ChatRoom{
        room_name: "room_random5",
        type: :public,
        inserted_at: now,
        updated_at: now,
        msg_duration_in_minutes: 5
      })

    %ChatRoom{id: get_id, room_name: get_room_name, msg_duration_in_minutes: duration} =
      from(x in ChatRoom) |> Repo.all() |> List.last()

    assert id == get_id
    assert room_name == get_room_name
    assert duration == 5
  end
end
