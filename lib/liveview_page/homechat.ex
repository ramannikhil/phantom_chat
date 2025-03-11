defmodule PhantomChatWeb.LiveviewPage.Homechat do
  use Phoenix.LiveView
  alias Hex.API.User
  alias PhantomChat.Schema.{User, Message}
  alias PhantomChat.Repo
  import Ecto.Query

  # attr :user_messages, PhantomChat.Schema.Message
  # attr :test_val, :integer, required: false

  def mount(_params, _session, socket) do
    # {:ok, assign(socket, :data, "Initial Value")}
    # IO.inspect(params, label: "check the params")
    # IO.inspect(session, label: "check the session in LV")

    if(connected?(socket)) do
      # todo replace with actual to generate the random username
      user_name =
        for _ <- 1..10, into: "", do: <<Enum.random(~c"01123456789abcdefghijklmnopqrstuvwxyz")>>

      {:ok, %User{id: user_id}} =
        Repo.insert(%User{
          name: user_name,
          inserted_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second),
          updated_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
        })

      socket = assign(socket, user_id: user_id)

      socket = assign(socket, user_messages: [])

      # IO.inspect(label: "mount called once")

      {:ok, socket}
    else
      {:ok, socket}
    end
  end

  def handle_event("send_message", %{"message" => message} = _params, socket) do
    user_id = Map.get(socket.assigns, :user_id)

    # IO.inspect(user_id, label: "called this send_message user_id ")

    # IO.inspect(socket.assigns, label: "check the socket.assigns ")

    Repo.insert(%Message{
      content: message,
      inserted_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second),
      updated_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second),
      user_id: user_id
    })

    user_messages = fetch_user_messages(user_id)
    # assign(socket, user_messages: user_messages)

    {:noreply, assign(socket, user_messages: user_messages)}
    # {:noreply, socket}
  end

  def handle_event("create_chat_room", _params, socket) do
    IO.inspect(label: "called this create_chat_room ")
    # todo this redirects between LV and phoenix pages
    # {:noreply, redirect(socket, to: "/chat")}
    {:noreply, socket}
  end

  #  todo remove this one
  #  todo implement Repository pattern for DB interactions
  def fetch_user_messages(user_id) do
    from(x in Message, where: x.user_id == ^user_id)
    |> Repo.all()
    |> Enum.map(fn x -> x.content end)
  end

  # def render(%{user_id: user_id} = assigns) when not is_nil(user_id) do
  def render(assigns) do
    # IO.inspect(assigns, label: "check the assigns")

    ~H"""
    <%!-- <div phx-click="create_chat_room" class="relative size-32 ...">
      <div class="absolute inset-x-full top-10 right-0 size-16 ...">
        Create ChatRoom
      </div>
    </div> --%>

    <%!-- <form phx-submit="send_message" class="w-full max-w-sm">
      <div class="space-y-12">
        <input
          type="text"
          name="message"
          class="placeholder:text-gray-500 placeholder:italic ..."
          placeholder="Enter message..."
        />
        <input
          type="submit"
          value="Submit"
          class="bg-blue-500  hover:bg-blue-700 text-white font-bold py-2 px-4 rounded-full"
        />
      </div>
    </form> --%>

    <%!-- <ul>
      <%= for user <- @user_messages do %>
        <li>{user}</li>
      <% end %>
    </ul> --%>
    <div class="flex justify-center p-10">
      <h3>
        Users message
      </h3>
      <div class="p-10 m-10">
        <label> Enter the message </label>
        <input
          class="block text-gray-500 font-bold md:text-right mb-1 md:mb-0 pr-4"
          id="chat-input"
          type="text"
        />
        <div class="p-5" id="messages" role="log" aria-live="polite">
          <%!-- <span>Time left</span> --%>
          <%!-- <span class="p-5" id="timeleft"></span> --%>
        </div>
      </div>
    </div>
    """
  end

  # def render(assigns) do
  #   ~H"""
  #   NOT NIL
  #   """
  # end
end
