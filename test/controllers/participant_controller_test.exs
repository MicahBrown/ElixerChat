defmodule Daychat.ParticipantControllerTest do
  use Daychat.ConnCase

  import Daychat.Fixtures

  alias Daychat.Participant
  alias Daychat.Chat
  @valid_attrs %{position: 42}

  test "renders form for new resources", %{conn: conn} do
    chat = fixture!(:chat)
    conn = get conn, chat_participant_path(conn, :new, chat.token)
    assert html_response(conn, 200) =~ "ParticipantNewView"
  end

  test "redirects to expired status page if chat has expired", %{conn: conn} do
    day_in_seconds = (24 * 60 * 60) + 1
    time_in_seconds = Ecto.DateTime.utc |> Ecto.DateTime.to_erl |> :calendar.datetime_to_gregorian_seconds
    day_ago_datetime = (time_in_seconds - day_in_seconds) |> :calendar.gregorian_seconds_to_datetime |> Ecto.DateTime.from_erl

    chat = fixture!(:chat)
    changeset = Chat.changeset(chat) |> put_change(:inserted_at, day_ago_datetime)
    expired_chat = Repo.update!(changeset)

    conn = get conn, chat_participant_path(conn, :new, expired_chat.token)
    assert redirected_to(conn) == "/expired"
  end

  test "renders maxed limit status page if chat has 20 participants", %{conn: conn} do
    maxed_chat = fixture!(:chat) |> add_participants(20)

    conn = get conn, chat_participant_path(conn, :new, maxed_chat.token)
    assert html_response(conn, 200) =~ "ParticipantMaxedView"
  end

  defp add_participants(chat, n) when n < 0, do: chat
  defp add_participants(chat, n) do
    chat = Repo.get!(Chat, chat.id)
    user = fixture!(:user)

    Participant.changeset(%Participant{user: user, chat: chat}) |> Repo.insert!

    add_participants(chat, n - 1)
  end

  test "renders page not found when chat id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, chat_participant_path(conn, :new, -1)
    end
  end

  test "creates resource and redirects when recaptcha is verified", %{conn: conn} do
    chat = fixture!(:chat)
    conn = post conn, chat_participant_path(conn, :create, chat.token, "g-recaptcha-response": true), participant: @valid_attrs
    assert redirected_to(conn) == chat_path(conn, :show, chat.token)
  end

  test "redirects to new participant page if recaptcha response is invalid", %{conn: conn} do
    chat = fixture!(:chat)
    conn = post conn, chat_participant_path(conn, :create, chat.token, "g-recaptcha-response": "invalid"), participant: @valid_attrs
    assert redirected_to(conn) == chat_participant_path(conn, :new, chat.token)
  end
end
