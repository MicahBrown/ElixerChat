defmodule Daychat.MessageControllerTest do
  use Daychat.ConnCase

  import Daychat.Fixtures

  alias Daychat.Chat
  @valid_attrs %{body: "some content"}

  # setup %{conn: conn} do
  #   {:ok, conn: put_req_header(conn, "accept", "application/json")}
  # end

  test "redirects to expired status page if chat has expired", %{conn: conn} do
    day_in_seconds = (24 * 60 * 60) + 1
    time_in_seconds = Ecto.DateTime.utc |> Ecto.DateTime.to_erl |> :calendar.datetime_to_gregorian_seconds
    day_ago_datetime = (time_in_seconds - day_in_seconds) |> :calendar.gregorian_seconds_to_datetime |> Ecto.DateTime.from_erl

    chat = fixture!(:chat)
    changeset = Chat.changeset(chat) |> put_change(:inserted_at, day_ago_datetime)
    expired_chat = Repo.update!(changeset)

    conn = post conn, chat_message_path(conn, :create, expired_chat.token), message: @valid_attrs
    assert redirected_to(conn) == "/expired"
  end

  test "renders page not found when chat id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      post conn, chat_message_path(conn, :create, -1), message: @valid_attrs
    end
  end
end
