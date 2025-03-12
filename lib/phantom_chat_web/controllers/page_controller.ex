defmodule PhantomChatWeb.PageController do
  use PhantomChatWeb, :controller
  alias PhantomChat.Schema.ChatRoom
  alias PhantomChat.Repo
  import Plug.Conn
  import Ecto.Query
  alias Helper.Service.ChatRoom, as: ChatRoomService

  @default_msg_duration 5

  def home(conn, _params) do
    render(conn, :home, layout: false)
  end

  def new_room(conn, %{"room_name" => room_name, "message_duration" => message_duration}) do
    message_duration =
      case Integer.parse(message_duration) do
        :error -> @default_msg_duration
        {duration, _} -> duration
      end

    {:ok, %ChatRoom{room_name: room_name}} =
      ChatRoomService.create_chat_room(room_name, message_duration)

    conn
    |> put_flash(:info, "Room created successfully. #{room_name}")
    |> redirect(to: "/chatroom/#{room_name}")
  end

  def new_room(conn, _params) do
    render(conn, :new_room, layout: false)
  end

  def join_room(conn, %{"room_name" => room_name}) do
    conn
    |> put_flash(:info, "Room joined successfully. #{room_name}")
    |> redirect(to: "/chatroom/#{room_name}")
  end

  def join_room(conn, _params) do
    render(conn, :join_room, layout: false)
  end

  def chatroom(conn, %{"room_name" => chat_room_name} = _params) do
    user_id_from_session = get_session(conn, :user_id)
    user_name_from_session = get_session(conn, :user_name)

    GenServer.cast(
      Helper.HandleRefreshNewLogin,
      {:set_user_refresh, user_id_from_session, chat_room_name}
    )

    from(x in ChatRoom, where: x.room_name == ^chat_room_name)
    |> Repo.exists?()
    |> case do
      true ->
        user_id = get_session(conn, :user_id)

        render(conn, :chatroom,
          layout: false,
          chat_room_name: chat_room_name,
          user_id: user_id,
          user_name: user_name_from_session
        )

      false ->
        conn
        |> put_flash(:error, "Invalid Room name")
        |> render(:chatroom_error,
          error_message: "Chat Room doesnot Exist, Please check the room code"
        )
    end
  end
end
