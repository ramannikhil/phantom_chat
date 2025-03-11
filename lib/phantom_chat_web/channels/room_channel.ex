defmodule PhantomChatWeb.RoomChannel do
  use Phoenix.Channel

  alias PhantomChat.Schema.{Message, ChatRoom, User}
  import Ecto.Query
  alias PhantomChat.Repo
  # todo handle the private room later

  # def join("room:lobby", meesage_payload, socket) do
  #   IO.inspect(meesage_payload, label: "check the meesage_payload")
  #   socket = assign(socket, temp_val: meesage_payload["temp_val"])
  #   {:ok, socket}
  # end

  def join("room_" <> room_name, meesage_payload, socket) do
    # IO.inspect(socket, label: "check the socket in the room_channel")
    IO.inspect(room_name, label: "check the room_name in the room_channel")
    IO.inspect(meesage_payload, label: "check the meesage_payload in the room_channel")
    # socket = assign(socket, temp_val: meesage_payload["temp_val"])

    send(self(), :after_join)
    {:ok, socket}
  end

  def handle_info(:after_join, socket) do
    user_id = Map.get(socket.assigns, :user_id, nil)
    chatroom_name = Map.get(socket.assigns, :topic, nil)

    user_state =
      GenServer.call(Helper.HandleRefreshNewLogin, :get_state)
      |> Map.get(user_id, false)

    IO.inspect(user_id, label: "check the user_id test ")
    IO.inspect(user_state, label: "check the user_state test ")
    # IO.inspect(GenServer.call(Helper.HandleRefreshNewLogin, :get_state),
    #   label: "check the user_state from the GENserver"
    # )

    if(user_state) do
      # GenServer.cast(Helper.HandleRefreshNewLogin, {:update_user_refresh, user_id})
      GenServer.cast(Helper.HandleRefreshNewLogin, {:set_or_update_user_refresh, user_id})

      # todo update the chatroom_id
      chat_room_messages =
        from(m in Message,
          join: u in assoc(m, :user),
          join: c in assoc(m, :chatroom),
          where: c.room_name == ^chatroom_name,
          select: %{message: m.content, created_at: m.inserted_at, user_name: u.name}
        )
        |> Repo.all()

      broadcast(socket, "old_messages", %{messages: chat_room_messages})
    end

    {:noreply, socket}
  end

  def handle_in("new_message", %{"message" => message}, socket) do
    #  todo move this logic to helper functions to get/ set the messages
    #  NOTE: todo fix the logic since this was bad approach sending all the messages from the chat_room to load
    #  todo this is temporary code only

    # creates message use helper func async and await
    # |> String.to_integer()
    # |> String.to_integer()
    user_id = Map.get(socket.assigns, :user_id, nil)
    IO.inspect(user_id, label: "check the user_id test new_message ")
    chatroom_name = Map.get(socket.assigns, :topic, nil)

    # two ways to get the chat_room_id ,
    #  1. Query based on the chat_room_name
    #  2. pass the chatroom_id like wise we did for chatroom_name

    chatroom_id =
      from(x in ChatRoom, where: x.room_name == ^chatroom_name, select: x.id) |> Repo.one()

    # todo maybe use mutli for more operations like create message, update user and chatroom
    {:ok, created_message} =
      Repo.insert(%Message{
        content: message,
        inserted_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second),
        updated_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second),
        user_id: user_id,
        chatroom_id: chatroom_id
      })

    # todo once the message is created updated the user and chatroom, updated_at values

    now = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
    IO.inspect(now, label: "check the value")

    {:ok, _updated_user} =
      Repo.get(User, user_id) |> Ecto.Changeset.change(updated_at: now) |> Repo.update()

    {:ok, _updated_chatroom} =
      Repo.get(ChatRoom, chatroom_id) |> Ecto.Changeset.change(updated_at: now) |> Repo.update()

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
      user_name: user_name
    })

    {:noreply, socket}
  end

  def handle_in("user_disconnected", %{"user_id" => user_id} = _payload, socket) do
    # persist the messages to genserver or each messages is persisted ?
    # todo configure this code?
    #  todo handle user_disconnected, not required I guess

    # GenServer.cast(Helper.HandleRefreshNewLogin, {:set_user_refresh, user_id |> String.to_integer()})
    GenServer.cast(
      Helper.HandleRefreshNewLogin,
      {:set_or_update_user_refresh, user_id |> String.to_integer()}
    )

    {:noreply, socket}
  end
end
