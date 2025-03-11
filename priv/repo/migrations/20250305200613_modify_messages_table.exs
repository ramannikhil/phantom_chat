defmodule PhantomChat.Repo.Migrations.ModifyMessagesTable do
  use Ecto.Migration

  def change do
    alter table("messages") do
      add(:msg_duration_in_minutes, :integer, default: 5)
    end
  end
end
