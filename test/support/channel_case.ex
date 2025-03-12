defmodule PhantomChatWeb.ChannelCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      # Import conveniences for testing channels
      # use Phoenix.ChannelTest
      import Phoenix.ChannelTest

      # The default endpoint for testing
      @endpoint PhantomChatWeb.Endpoint

      # Allow using Ecto helpers
      import Ecto.Query
      import PhantomChat.Repo

      # Import helpers for test setup
      import PhantomChatWeb.ChannelCase
    end
  end

  setup _tags do
    :ok
  end
end
