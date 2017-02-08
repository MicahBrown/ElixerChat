defmodule Daychat.SearchController do
  use Daychat.Web, :controller

  alias Daychat.Chat

  def show(conn, %{"q" => token}) do
    chat = Repo.get_by(Chat, token: token)

    render(conn, "show.json", chat: chat)
  end
end