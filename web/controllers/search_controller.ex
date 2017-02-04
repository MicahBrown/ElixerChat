defmodule Daychat.SearchController do
  use Daychat.Web, :controller

  alias Daychat.Chat

  def index(conn, %{"q" => token}) do
    chat = Repo.get_by(Chat, token: token)

    render(conn, "index.json", chat: chat)
  end
end