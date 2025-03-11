defmodule TryPlug.CustomPlug do
  import Plug.Conn
  alias PhantomChat.Schema.User
  alias PhantomChat.Repo
  # todo use this to put only user_id in the socket and access the same in the
  # import Phoenix.Socket

  def init(opts), do: opts

  # def call(conn, _default) do
  #   {user_id, _user_name} = create_new_user()
  #   put_session(conn, :user_id, user_id)
  # end

  def call(conn, _default) do
    get_session(conn, :user_id)
    |> IO.inspect(label: "check the conn first fetch")

    user_id_from_conn = get_session(conn, :user_id) || get_cookie_user_id(conn)

    IO.inspect(user_id_from_conn, label: "check the user_id_from_conn")

    { get_user_id, get_user_name} =
      case user_id_from_conn do
        nil ->
          create_new_user()

        user_id_from_conn ->
          { user_id_from_conn, "temp value"}
          # id -> get_cookie_user_id(conn)
          # _ -> get_cookie_user_id(conn)
      end

    # conn = put_session(conn, :user_id, get_user_id)

    IO.inspect(get_user_id, label: "check the output get_user_id")

    conn =
      conn
      |> put_session(:user_id, get_user_id)
      |> put_session(:user_name, get_user_name)
      |> put_resp_cookie("user-cookie", %{user_id: get_user_id},
        sign: true,
        max_age: 60 * 60 ,
        http_only: true
      )
      #  todo fix this
      |> assign(:current_user, get_user_id)

    get_session_user_id = get_session(conn, :user_id)

    IO.inspect(get_session_user_id, label: "check the get_session_user_id")

    conn
  end

  defp get_cookie_user_id(conn) do
    # conn = conn |> fetch_cookies()

    # conn |> IO.inspect(label: "check the fetch_cookies vals")

    # user_id_cookie_from_conn =
    #   case Map.get(conn, :req_cookies) do
    #     %{"user_id" => user_id} -> user_id
    #     %{} -> nil
    #   end

    # Map.get(conn, :req_cookies)
    # |> IO.inspect(label: "chcek the  req_cookies")

    # user_id_cookie_from_conn

    #   user_id_cookie_from_conn = Map.get(conn.resp_cookies, :user_id, nil)
    #   IO.inspect(user_id_cookie_from_conn,
    #   label: "checj the get_cookie_user_id in the fecth cookies "
    # )
    # user_id_cookie_from_conn

    conn =
      conn
      |> fetch_cookies(signed: ~w(user-cookie))

    IO.inspect(conn.req_cookies, label: "check the conn.req_cookies in fecth cookies")
    user_id = Map.get(conn.req_cookies, :user_id, nil)

    # IO.inspect(vals, label: "check the conn.req_cookies in fecth cookies")
    # conn
    user_id
  end

  defp create_new_user() do
    user_name =
      "User-" <>
        for _ <- 1..8, into: "", do: <<Enum.random(Enum.concat([?0..?9, ?A..?Z, ?a..?z]))>>

    {:ok, %User{id: user_id}} =
      Repo.insert(%User{
        name: user_name,
        inserted_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second),
        updated_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
      })

    {user_id, user_name}
  end
end
