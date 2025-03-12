defmodule PhantomChat.Channel.ChatTest do
  # use PhantomChatWeb.ChannelCase, async: true
  use PhantomChatWeb.ChannelCase, async: false

  alias PhantomChatWeb.UserChatSocket
  alias PhantomChatWeb.RoomChannel

  alias Helper.Service.User, as: UserService
  alias Helper.Service.ChatRoom, as: ChatRoomService
  alias PhantomChat.Schema.{User, ChatRoom}

  setup do
    PhantomChat.Repo.delete_all(PhantomChat.Schema.ChatRoom)
    PhantomChat.Repo.delete_all(PhantomChat.Schema.User)
    PhantomChat.Repo.delete_all(PhantomChat.Schema.Message)

    {:ok, %User{id: user_id}} = UserService.create_user("user_nikhil")
    {:ok, %ChatRoom{room_name: chat_room_name}} = ChatRoomService.create_chat_room("testing", 5)

    {:ok, socket} =
      UserChatSocket
      |> connect(%{"user_id" => user_id |> to_string(), "topic" => chat_room_name})

    {:ok, _, socket} = subscribe_and_join(socket, RoomChannel, chat_room_name)

    %{socket: socket, user_id: user_id, chat_room_name: chat_room_name}
  end

  test "joining a room assigns correct topic" do
    {:ok, %User{id: user_id}} = UserService.create_user("user_nikhil")
    {:ok, %ChatRoom{room_name: chat_room_name}} = ChatRoomService.create_chat_room("testing", 5)

    {:ok, socket} =
      UserChatSocket
      |> connect(%{"user_id" => user_id |> to_string(), "topic" => chat_room_name})

    {:ok, _, socket} = subscribe_and_join(socket, RoomChannel, chat_room_name)
    assert socket.assigns.topic == "room_testing"
  end

  test "handle_in new_message broadcasts message", %{socket: socket} do
    push(socket, "new_message", %{"message" => "Hello!"})

    assert_broadcast "new_message", %{message: "Hello!"}
  end

  test "handle_info :after_join sends old messages", %{
    socket: socket,
    user_id: user_id,
    chat_room_name: chat_room_name
  } do
    GenServer.cast(Helper.HandleRefreshNewLogin, {:set_user_refresh, user_id, chat_room_name})

    send(socket.channel_pid, :after_join)

    assert_broadcast "old_messages", _
  end
end
