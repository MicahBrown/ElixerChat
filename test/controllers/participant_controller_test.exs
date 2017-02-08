defmodule Daychat.ParticipantControllerTest do
  use Daychat.ConnCase

  alias Daychat.Participant
  @valid_attrs %{position: 42}
  @invalid_attrs %{}

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
end
