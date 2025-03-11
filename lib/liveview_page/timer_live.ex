defmodule PhantomChatWeb.LiveviewPage.TimerLive do
  # use MyAppWeb, :live_view
  use Phoenix.LiveView
  # alias Phoenix.LiveView

  # 1 second
  @interval 1000

  def mount(_params, _session, socket) do
    if connected?(socket), do: :timer.send_interval(@interval, self(), :tick)
    {:ok, assign(socket, :time, format_time())}
  end

  def handle_info(:tick, socket) do
    {:noreply, assign(socket, :time, format_time())}
  end

  defp format_time do
    DateTime.utc_now() |> DateTime.to_string()
  end

  def render(assigns) do
    ~H"""
    <div>
      <h1>Live Timer</h1>
      <p><strong>Current Time:</strong> {@time}</p>
    </div>
    """
  end
end
