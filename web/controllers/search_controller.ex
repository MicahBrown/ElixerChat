defmodule Daychat.SearchController do
  use Daychat.Web, :controller

  alias Daychat.Chat

  def show(conn, %{"q" => token}) do
    pk    = String.downcase(token)
    query = from c in Chat,
              where: fragment("lower(?)", c.token) == ^pk,
              limit: 1
    chat  = Repo.all(query) |> List.first

    render(conn, "show.json", chat: chat)
  end
end