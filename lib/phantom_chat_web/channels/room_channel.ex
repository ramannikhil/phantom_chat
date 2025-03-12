defmodule PhantomChatWeb.RoomChannel do
  use Phoenix.Channel

  alias PhantomChat.Schema.{Message, ChatRoom, User}
  import Ecto.Query
  alias PhantomChat.Repo
  alias Helper.Service.Message, as: MessageService
  alias Helper.Service.User, as: UserService
  alias Helper.Service.ChatRoom, as: ChatRoomService
  # todo handle the private room later

  def join("room_" <> _room_name, _meesage_payload, socket) do
    send(self(), :after_join)
    {:ok, socket}
  end

  def handle_info(:after_join, socket) do
    user_id = Map.get(socket.assigns, :user_id, nil)
    chatroom_name = Map.get(socket.assigns, :topic, nil)

    user_state =
      GenServer.call(Helper.HandleRefreshNewLogin, :get_state)
      |> Map.get(chatroom_name, %{})
      |> Map.get(user_id, false)

    if(user_state) do
      GenServer.cast(Helper.HandleRefreshNewLogin, {:update_user_refresh, user_id, chatroom_name})

      # retreieve only the messages that were created before x min based on the chatroom configuration
      %ChatRoom{msg_duration_in_minutes: message_duration} =
        Repo.get_by(ChatRoom, room_name: chatroom_name)

      chatroom_duration_ago =
        NaiveDateTime.utc_now() |> NaiveDateTime.add(-message_duration * 60, :second)

      chat_room_messages =
        from(m in Message,
          join: u in assoc(m, :user),
          join: c in assoc(m, :chatroom),
          where: c.room_name == ^chatroom_name,
          where: m.inserted_at >= ^chatroom_duration_ago,
          select: %{
            message: m.content,
            created_at: m.inserted_at,
            user_name: u.name,
            chat_duration: c.msg_duration_in_minutes
          }
        )
        |> Repo.all()

      broadcast(socket, "old_messages", %{messages: chat_room_messages})
    end

    {:noreply, socket}
  end

  def handle_in("new_message", %{"message" => message}, socket) do
    user_id = Map.get(socket.assigns, :user_id, nil)
    chatroom_name = Map.get(socket.assigns, :topic, nil)

    {chatroom_id, chat_duration} =
      from(x in ChatRoom,
        where: x.room_name == ^chatroom_name,
        select: {x.id, x.msg_duration_in_minutes}
      )
      |> Repo.one()

    {:ok, created_message} =
      MessageService.create_message(message, chatroom_id, user_id)

    {:ok, _updated_user} = UserService.update_user(user_id)
    {:ok, _updated_chatroom} = ChatRoomService.update_chat_room(chatroom_id)

    %Message{
      content: message_content,
      inserted_at: created_at,
      user: %User{
        name: user_name
      }
    } =
      created_message |> Repo.preload([:user])

    broadcast(socket, "new_message", %{
      message: message_content,
      created_at: created_at,
      user_name: user_name,
      chat_duration: chat_duration
    })

    {:noreply, socket}
  end

  def handle_in("user_disconnected", %{"user_id" => user_id} = _payload, socket) do
    chatroom_name = Map.get(socket.assigns, :topic, nil)

    GenServer.cast(
      Helper.HandleRefreshNewLogin,
      {:set_user_refresh, user_id |> String.to_integer(), chatroom_name}
    )

    {:noreply, socket}
  end
end
