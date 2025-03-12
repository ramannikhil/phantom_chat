defmodule PhantomChat.Workers.DeleteInactiveUsers do
  use Oban.Worker, queue: :default

  import Ecto.Query
  alias PhantomChat.Repo
  alias PhantomChat.Schema.User

  @threshold_minutes 30

  @impl Oban.Worker
  def perform(%Oban.Job{}) do
    threshold_time = DateTime.utc_now() |> DateTime.add(-@threshold_minutes * 60, :second)

    query = from(u in User, where: u.updated_at < ^threshold_time)

    if(query |> Repo.all() |> Enum.count() != 0) do
      query |> Repo.delete_all()
    end

    :ok
  end
end
