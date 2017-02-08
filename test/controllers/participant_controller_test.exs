defmodule Daychat.ParticipantControllerTest do
  use Daychat.ConnCase

  alias Daychat.Participant
  alias Daychat.Chat
  @valid_attrs %{position: 42}
  @invalid_attrs %{}

  test "renders form for new resources", %{conn: conn} do
    chat = Repo.insert! %Chat{}
    conn = get conn, chat_participant_path(conn, :new, chat)
    assert html_response(conn, 200) =~ "New participant"
  end

  test "creates resource and redirects when data is valid", %{conn: conn} do
    chat = Repo.insert! %Chat{}
    conn = post conn, chat_participant_path(conn, :create, chat), participant: @valid_attrs
    # assert redirected_to(conn) == chat_participant_path(conn, :index)
    assert Repo.get_by(Participant, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    chat = Repo.insert! %Chat{}
    conn = post conn, chat_participant_path(conn, :create, chat), participant: @invalid_attrs
    assert html_response(conn, 200) =~ "New participant"
  end
end
