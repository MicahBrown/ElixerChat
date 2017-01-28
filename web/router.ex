defmodule Daychat.Router do
  use Daychat.Web, :router

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

  scope "/", Daychat do
    pipe_through :browser # Use the default browser stack

    resources "/chats", ChatController, only: [:new, :create, :show] do
      resources "/participants", ParticipantController, only: [:new, :create]
      resources "/messages", MessageController, only: [:create]
    end

    get "/", PageController, :index, as: :root
  end

  # Other scopes may use custom stacks.
  # scope "/api", Daychat do
  #   pipe_through :api
  # end
end
