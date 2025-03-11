defmodule PhantomChatWeb.PageController do
  use PhantomChatWeb, :controller
  alias PhantomChat.Schema.ChatRoom
  alias PhantomChat.Repo
  import Plug.Conn
  import Ecto.Query

  def home(conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.
    #   IO.puts """
    # Verb: #{inspect(conn.method)}
    # Host: #{inspect(conn.host)}
    # Headers: #{inspect(conn.req_headers)}
    # conn: #{inspect(conn)}
    # """
    # put_flash(conn, :info, "todo ")
    # |> render(:home, layout: false)

    render(conn, :home, layout: false)
  end

  # chat_room_id from the route
  # def chatroom(conn, %{"id" => chat_room_id} = _params) do

  #   chat_room_name =
  #     from(x in ChatRoom, where: x.id == ^chat_room_id, select: x.room_name) |> Repo.one()

  #   %{"user_id" => user_id} = get_session(conn)

  #   render(conn, :chatroom, layout: false, chat_room_name: chat_room_name, user_id: user_id)
  # end

  def chatroom(conn, %{"room_name" => chat_room_name} = _params) do
    user_id_from_session = get_session(conn, :user_id)
    user_name_from_session = get_session(conn, :user_name)
    IO.inspect(user_id_from_session, label: "check the user_id_from_session ")

    # GenServer.cast(Helper.HandleRefreshNewLogin, {:set_user_refresh, user_id_from_session})
    GenServer.cast(
      Helper.HandleRefreshNewLogin,
      {:set_or_update_user_refresh, user_id_from_session}
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
        render(conn, :chatroom_error,
          error_message: "Chat Room doesn't Exist, Please check the room code"
        )
    end
  end
end
