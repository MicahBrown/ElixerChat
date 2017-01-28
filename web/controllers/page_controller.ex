defmodule Daychat.PageController do
  use Daychat.Web, :controller

  def index(conn, _params) do
    changeset = Daychat.Chat.new_changeset(%Daychat.Chat{})
    render(conn, "index.html", changeset: changeset)
  end
end
