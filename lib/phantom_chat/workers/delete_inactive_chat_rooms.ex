defmodule PhantomChat.Workers.DeleteInactiveChatRooms do
  use Oban.Worker, queue: :default

  import Ecto.Query
  alias PhantomChat.Repo
  alias PhantomChat.Schema.ChatRoom

  @threshold_hour 1

  @impl Oban.Worker
  def perform(%Oban.Job{}) do
    threshold_time = DateTime.utc_now() |> DateTime.add(-@threshold_hour * 24, :hour)

    query = from(u in ChatRoom, where: u.updated_at < ^threshold_time)

    if(query |> Repo.all() |> Enum.count() != 0) do
      query |> Repo.delete_all()
    end

    :ok
  end
end
