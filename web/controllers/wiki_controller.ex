defmodule Daychat.WikiController do
  use Daychat.Web, :controller

  def show(conn, %{"id" => id}) do
    case id do
      "markdown" ->
        render(conn, "show.html", wiki: id)
      _ ->
        conn
        |> put_status(:not_found)
        |> render(Daychat.ErrorView, "404.html")
    end
  end
end