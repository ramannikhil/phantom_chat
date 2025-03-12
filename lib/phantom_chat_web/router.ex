defmodule PhantomChatWeb.Router do
  use PhantomChatWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {PhantomChatWeb.Layouts, :root}
    # plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Helper.Plug.UserAuth
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", PhantomChatWeb do
    pipe_through [:browser]

    get "/home", PageController, :home
    get "/new_room", PageController, :new_room
    post "/new_room", PageController, :new_room

    get "/join_room", PageController, :join_room
    post "/join_room", PageController, :join_room

    get "/chatroom/:room_name", PageController, :chatroom
  end

  scope "/", PhantomChatWeb do
    pipe_through [:browser]
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
