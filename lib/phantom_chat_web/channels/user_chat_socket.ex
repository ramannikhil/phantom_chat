defmodule PhantomChatWeb.UserChatSocket do
  use Phoenix.Socket
  channel "room_*", PhantomChatWeb.RoomChannel

  @impl true
  def connect(params, socket, _connect_info) do
    socket =
      assign(socket, :topic, params["topic"])
      |> assign(:user_id, params["user_id"] |> String.to_integer())

    {:ok, socket}
  end

  @impl true
  def id(_socket), do: nil
end
