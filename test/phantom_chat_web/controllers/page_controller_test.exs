defmodule PhantomChatWeb.PageControllerTest do
  alias PhantomChat.Schema.{ChatRoom, User}
  use PhantomChatWeb.ConnCase
  alias PhantomChat.Repo
  import Ecto.Query
  alias Helper.Service.ChatRoom, as: ChatRoomService

  test "GET /home", %{conn: conn} do
    conn = get(conn, ~p"/home")
    assert html_response(conn, 200) =~ "Create Room"
    assert html_response(conn, 200) =~ "Join Room"
  end

  test "GET create new room page form", %{conn: conn} do
    conn = get(conn, ~p"/new_room")

    assert html_response(conn, 200) =~ "Room Name"
    assert html_response(conn, 200) =~ "Create Room"
    assert html_response(conn, 200) =~ "Message Duration (minutes)"
  end

  test "POST create new room", %{conn: conn} do
    params = %{"room_name" => "test1", "message_duration" => "10"}
    conn = post(conn, "/new_room", params)

    # fetch the user_name, user_id from the conn
    user_name = get_session(conn, :user_name)
    user_id = get_session(conn, :user_id)

    %ChatRoom{room_name: room_name} = from(x in ChatRoom) |> Repo.all() |> List.last()

    %User{id: get_user_id, name: get_user_name} = from(x in User) |> Repo.all() |> List.last()

    # check the user_id is created through the custom plug, Helper.Plug.UserAuth
    assert user_name == get_user_name
    assert user_id == get_user_id

    assert room_name == "room_test1"
    assert redirected_to(conn, 302) =~ "/chatroom/room_test1"

    assert Phoenix.Flash.get(conn.assigns.flash, :info) ==
             "Room created successfully. #{room_name}"
  end

  test "GET Join room", %{conn: conn} do
    room_name = "room_testroom2"

    {:ok, %ChatRoom{room_name: created_room_name}} =
      ChatRoomService.create_chat_room(room_name, 10)

    conn = get(conn, ~p"/chatroom/#{created_room_name}")

    user_name = get_session(conn, :user_name)

    assert html_response(conn, 200) =~ "Chat Room"
    assert html_response(conn, 200) =~ "#{created_room_name}"
    assert html_response(conn, 200) =~ "#{user_name}"

    assert html_response(conn, 200) =~ "Enter the message"
    assert html_response(conn, 200) =~ "Go to Home"
  end

  test "POST error on routing to incorrect chatroom", %{conn: conn} do
    room_name = "invalid_room_name"
    conn = get(conn, ~p"/chatroom/#{room_name}")

    assert html_response(conn, 200) =~ "Chat Room doesnot Exist, Please check the room code"
    assert Phoenix.Flash.get(conn.assigns.flash, :error) == "Invalid Room name"
  end
end
