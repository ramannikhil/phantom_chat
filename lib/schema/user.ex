defmodule PhantomChat.Schema.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias PhantomChat.Schema.Message

  schema "users" do
    # todo add unique constraint on name
    field(:name, :string)
    field(:inserted_at, :naive_datetime)
    field(:updated_at, :naive_datetime)
    has_many(:messages, Message)
  end

  def changeset(user, params \\ %{}) do
    user
    |> cast(params, [:id, :name, :updated_at, :inserted_at])
  end
end
