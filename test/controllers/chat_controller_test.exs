defmodule Daychat.ChatControllerTest do
  use Daychat.ConnCase

  import Daychat.Fixtures

  alias Daychat.Repo
  alias Daychat.Chat
  # alias Daychat.Participant
  @valid_attrs %{}
  @invalid_attrs %{}

  test "shows expired status on index", %{conn: conn} do
    conn = get conn, expired_chat_path(conn, :index)
    assert html_response(conn, 200) =~ "ChatExpiredView"
  end

  test "redirects to root on new", %{conn: conn} do
    conn = get conn, chat_path(conn, :new)
    assert redirected_to(conn) == root_path(conn, :index)
  end

  test "creates resource and redirects when recaptcha is verified", %{conn: conn} do
    conn = post conn, chat_path(conn, :create, "g-recaptcha-response": true), chat: @valid_attrs
    user_id = conn.assigns[:current_user].id
    token =
      redirected_to(conn)
      |> String.split("/")
      |> List.last

    assert Repo.get_by(Chat, token: token, user_id: user_id)
  end

  test "does not create resource and redirects to root when recaptcha response is invalid", %{conn: conn} do
    conn = post conn, chat_path(conn, :create), chat: @invalid_attrs
    assert redirected_to(conn) == root_path(conn, :index)
  end

  # test "shows chosen resource if participant link exists for current user", %{conn: conn} do
  #   user = fixture!(:user)
  #   chat = fixture!(:chat)
  #   link = Participant.changeset(%Participant{user: user, chat: chat}) |> Repo.insert!
  #   conn = put_session(conn, :user_id, user.auth_key)

  #   conn = get conn, chat_path(conn, :show, chat.token)
  #   assert html_response(conn, 200) =~ "Show chat"
  # end

  test "redirects to new participant page if no participant link exists for current user", %{conn: conn} do
    chat = fixture!(:chat)
    conn = get conn, chat_path(conn, :show, chat.token)
    assert redirected_to(conn) == chat_participant_path(conn, :new, chat.token)
  end

  test "redirects to expired status page if chat has expired", %{conn: conn} do
    day_in_seconds = (24 * 60 * 60) + 1
    time_in_seconds = Ecto.DateTime.utc |> Ecto.DateTime.to_erl |> :calendar.datetime_to_gregorian_seconds
    day_ago_datetime = (time_in_seconds - day_in_seconds) |> :calendar.gregorian_seconds_to_datetime |> Ecto.DateTime.from_erl

    chat = fixture!(:chat)
    changeset = Chat.changeset(chat) |> put_change(:inserted_at, day_ago_datetime)
    expired_chat = Repo.update!(changeset)

    conn = get conn, chat_path(conn, :show, expired_chat.token)
    assert redirected_to(conn) == "/expired"
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, chat_path(conn, :show, -1)
    end
  end
end
