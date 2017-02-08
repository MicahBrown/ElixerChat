defmodule Daychat.WikiControllerTest do
  use Daychat.ConnCase

  test "renders chosen wiki if it exists", %{conn: conn} do
    wiki = "markdown"
    conn = get conn, wiki_path(conn, :show, wiki)
    assert html_response(conn, 200) =~ "WikiShowView"
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    conn = get conn, wiki_path(conn, :show, -1)
    assert html_response(conn, 404) =~ "Error404View"
  end
end