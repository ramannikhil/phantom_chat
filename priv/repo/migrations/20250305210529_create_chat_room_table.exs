defmodule PhantomChat.Repo.Migrations.CreateChatRoomTable do
  use Ecto.Migration

  def change do
    execute "CREATE TYPE chatroom_type AS ENUM ('public', 'private')"

    create table("chatrooms") do
      add(:room_name, :string)
      add(:type, :chatroom_type, null: false, default: "public")
      add(:passcode, :string)

      timestamps()
    end
  end
end
