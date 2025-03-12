defmodule PhantomChat.Repo.Migrations.AddMessagesTable do
  use Ecto.Migration

  def change do
    create table("messages") do
      add(:content, :string)
      add(:user_id, references(:users, on_delete: :delete_all))

      timestamps()
    end
  end
end
