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

  # todo remove both the set_user_refresh, update_user_refresh
  @impl true
  def handle_cast({:set_user_refresh, user_id}, state) do
    IO.inspect(state, label: "check theuser_id_from_session new_state BEFORe ")
    new_state = Map.put(state, user_id, true)
    IO.inspect(new_state, label: "check theuser_id_from_session new_state ")
    {:noreply, new_state}
  end

  # todo update this logic to use single call,
  @impl true
  def handle_cast({:update_user_refresh, user_id}, state) do
    new_state = Map.update(state, user_id, false, fn x -> !x end)
    {:noreply, new_state}
  end

  @impl true
  def handle_cast({:set_or_update_user_refresh, user_id}, state) do
    new_state =
      Map.get(state, user_id, nil)
      |> case do
        nil -> Map.put(state, user_id, true)
        _ -> Map.update(state, user_id, false, fn x -> !x end)
      end

      IO.inspect(new_state, label: "check the handle_cast in the new_state in the GENSEVER")

    {:noreply, new_state}
  end

  @impl true
  def handle_call(:get_state, _from, state) do
    # used this only for retrieving the current state
    {:reply, state, state}
  end
end
