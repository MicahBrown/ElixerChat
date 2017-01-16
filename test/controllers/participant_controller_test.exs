defmodule Daychat.ParticipantControllerTest do
  use Daychat.ConnCase

  alias Daychat.Participant
  @valid_attrs %{position: 42}
  @invalid_attrs %{}

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, participant_path(conn, :index)
    assert html_response(conn, 200) =~ "Listing participants"
  end

  test "renders form for new resources", %{conn: conn} do
    conn = get conn, participant_path(conn, :new)
    assert html_response(conn, 200) =~ "New participant"
  end

  test "creates resource and redirects when data is valid", %{conn: conn} do
    conn = post conn, participant_path(conn, :create), participant: @valid_attrs
    assert redirected_to(conn) == participant_path(conn, :index)
    assert Repo.get_by(Participant, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, participant_path(conn, :create), participant: @invalid_attrs
    assert html_response(conn, 200) =~ "New participant"
  end

  test "shows chosen resource", %{conn: conn} do
    participant = Repo.insert! %Participant{}
    conn = get conn, participant_path(conn, :show, participant)
    assert html_response(conn, 200) =~ "Show participant"
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, participant_path(conn, :show, -1)
    end
  end

  test "renders form for editing chosen resource", %{conn: conn} do
    participant = Repo.insert! %Participant{}
    conn = get conn, participant_path(conn, :edit, participant)
    assert html_response(conn, 200) =~ "Edit participant"
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn} do
    participant = Repo.insert! %Participant{}
    conn = put conn, participant_path(conn, :update, participant), participant: @valid_attrs
    assert redirected_to(conn) == participant_path(conn, :show, participant)
    assert Repo.get_by(Participant, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    participant = Repo.insert! %Participant{}
    conn = put conn, participant_path(conn, :update, participant), participant: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit participant"
  end

  test "deletes chosen resource", %{conn: conn} do
    participant = Repo.insert! %Participant{}
    conn = delete conn, participant_path(conn, :delete, participant)
    assert redirected_to(conn) == participant_path(conn, :index)
    refute Repo.get(Participant, participant.id)
  end
end
