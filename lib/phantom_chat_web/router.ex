defmodule PhantomChatWeb.Router do
  use PhantomChatWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {PhantomChatWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :custom_plug do
    # todo for testing purpose only
    plug TryPlug.CustomPlug
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  #  todo cleanup router
  scope "/", PhantomChatWeb do
    pipe_through [:browser, :custom_plug]

    get "/", PageController, :home
    # get "/chatroom/:id", PageController, :chatroom
    get "/chatroom/:room_name", PageController, :chatroom
  end

  scope "/", PhantomChatWeb do
    pipe_through [:browser, :custom_plug]

    # live "/livechat", LiveviewPage.Homechat
    live "/timer", LiveviewPage.TimerLive
  end

  # Other scopes may use custom stacks.
  # scope "/api", PhantomChatWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:phantom_chat, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: PhantomChatWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
