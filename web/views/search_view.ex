defmodule Daychat.SearchView do
  use Daychat.Web, :view

  def render("show.json", %{chat: chat}) do
    %{data: render_one(chat, Daychat.SearchView, "chat.json")}
  end

  def render("chat.json", %{search: chat}) do
    %{token: chat.token}
  end
end