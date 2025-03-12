defmodule Helper.Plug.UserAuth do
  import Plug.Conn
  alias PhantomChat.Schema.User
  alias Helper.Service.User, as: UserService

  def init(opts), do: opts

  def call(conn, opts) do
    case get_session(conn, :user_name) do
      nil ->
        {user_id, user_name} = create_new_user()

        conn
        |> put_session(:user_name, user_name)
        |> put_session(:user_id, user_id)
        # 30 min expiry
        |> put_session(:expires_at, DateTime.utc_now() |> DateTime.add(1800, :second))
        |> assign(:user_name, user_name)

      user_name ->
        expires_at = get_session(conn, :expires_at)

        if DateTime.compare(DateTime.utc_now(), expires_at) == :gt do
          conn
          |> configure_session(drop: true)
          |> call(opts)
        else
          assign(conn, :user_name, user_name)
        end
    end
  end

  defp create_new_user() do
    user_name =
      "User-" <>
        for _ <- 1..8, into: "", do: <<Enum.random(Enum.concat([?0..?9, ?A..?Z, ?a..?z]))>>

    {:ok, %User{id: user_id}} = UserService.create_user(user_name)

    {user_id, user_name}
  end
end
