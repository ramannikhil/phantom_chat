defmodule Helper.HandleRefreshNewLogin do
  use GenServer

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  @impl true
  def init(_params) do
    initial_state = %{}
    {:ok, initial_state}
  end

  @impl true
  def handle_cast({:set_user_refresh, user_id, chatroom_name}, state) do
    new_state =
      if(Map.has_key?(state, chatroom_name)) do
        chatroom_state = Map.get(state, chatroom_name, nil)
        updated_state = Map.put(chatroom_state, user_id, true)
        Map.put(state, chatroom_name, updated_state)
      else
        Map.put(state, chatroom_name, %{user_id => true})
      end

    {:noreply, new_state}
  end

  @impl true
  def handle_cast({:update_user_refresh, user_id, chatroom_name}, state) do
    chatroom_state = Map.get(state, chatroom_name, nil)
    updated_state = Map.put(chatroom_state, user_id, false)
    new_state = Map.put(state, chatroom_name, updated_state)

    {:noreply, new_state}
  end

  @impl true
  def handle_call(:get_state, _from, state) do
    # used this only for retrieving the current state
    {:reply, state, state}
  end
end
