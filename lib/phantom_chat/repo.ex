defmodule PhantomChat.Repo do
  use Ecto.Repo,
    otp_app: :phantom_chat,
    adapter: Ecto.Adapters.Postgres
end
