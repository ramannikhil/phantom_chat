defmodule PhantomChat.Schema.Message do
  import Ecto.Changeset
  use Ecto.Schema
  alias PhantomChat.Schema.{User, ChatRoom}

  schema "messages" do
    field(:content, :string)
    field(:inserted_at, :naive_datetime)
    field(:updated_at, :naive_datetime)
    belongs_to(:user, User)
    belongs_to(:chatroom, ChatRoom)
  end

  def changeset(message, params \\ %{}) do
    message
    |> cast(params, [:id, :name, :user_id, :chatroom_id, :updated_at, :inserted_at])
    |> foreign_key_constraint(:user)
  end
end
