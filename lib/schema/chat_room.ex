defmodule PhantomChat.Schema.ChatRoom do
  import Ecto.Changeset
  use Ecto.Schema

  schema "chatrooms" do
    # todo modify this to room_code
    field(:room_name, :string)
    field(:type, Ecto.Enum, values: [:public, :private], default: :public)
    field(:passcode, :string)
    field(:inserted_at, :naive_datetime)
    field(:updated_at, :naive_datetime)
    # has_many(:messages, Messa)
  end

  def changeset(chatroom, params \\ %{}) do
    chatroom
    |> cast(params, [:room_name, :type, :passcode, :updated_at, :inserted_at])
    |> foreign_key_constraint(:user)
  end
end
