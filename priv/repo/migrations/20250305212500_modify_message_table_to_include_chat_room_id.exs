defmodule PhantomChat.Repo.Migrations.ModifyMessageTableToIncludeChatRoomId do
  use Ecto.Migration

  def change do
    alter table("messages") do
      add(:chatroom_id, references(:chatrooms, on_delete: :delete_all))
    end
  end
end
