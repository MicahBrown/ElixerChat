defmodule Daychat.SearchControllerTest do
  use Daychat.ConnCase

  import Daychat.Fixtures

  alias Daychat.Chat

  test "shows chosen resource", %{conn: conn} do
    chat = fixture!(:chat)
    conn = get conn, search_path(conn, :show, q: chat.token)
    assert json_response(conn, 200) == %{"data" => %{"token" => chat.token}}
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    conn = get conn, search_path(conn, :show, q: "nonexistent")
    assert json_response(conn, 200) == %{"data" => nil}
  end
end

# defmodule Daychat.SearchController do
#   use Daychat.Web, :controller

#   alias Daychat.Chat

#   def show(conn, %{"q" => token}) do
#     chat = Repo.get_by(Chat, token: token)

#     render(conn, "show.json", chat: chat)
#   end
# end