defmodule Daychat.PageControllerTest do
  use Daychat.ConnCase

  test "GET /", %{conn: conn} do
    conn = get conn, "/"
    assert html_response(conn, 200) =~ "PageIndexView"
  end
end
