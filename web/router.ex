defmodule Daychat.Router do
  use Daychat.Web, :router
  use Plug.ErrorHandler
  use Sentry.Plug
  import Authentication

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :auth do
    plug :set_current_user
  end

  scope "/", Daychat do
    pipe_through [:browser, :auth] # Use the default browser stack

    resources "/chats", ChatController, only: [:new, :create, :show] do
      resources "/participants", ParticipantController, only: [:new, :create]
      resources "/messages", MessageController, only: [:create]
    end

    get "/expired", ChatController, :index, as: :expired_chat

    resources "/wiki", WikiController, only: [:show]

    get "/search", SearchController, :show, as: :search
    get "/", PageController, :index, as: :root
  end

  # Other scopes may use custom stacks.
  # scope "/api", Daychat do
  #   pipe_through :api
  # end

  # Below scope skips the authentication
  # scope "/", Daychat do
  #   pipe_through :browser

  #   get "/login", SessionsController, :login
  # end
end
