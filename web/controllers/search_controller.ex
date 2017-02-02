defmodule Daychat.SearchController do
  use Daychat.Web, :controller

  alias Daychat.Chat

  def index(conn, %{"search" => %{"name" => name}}) do
    chat = Repo.get_by(Chat, name: name)

    render(conn, "index.json", chat: chat)
  end
end