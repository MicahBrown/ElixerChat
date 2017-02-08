defmodule Daychat.MessageControllerTest do
  use Daychat.ConnCase

  alias Daychat.Message
  alias Daychat.Chat
  @valid_attrs %{body: "some content"}
  @invalid_attrs %{}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "creates and renders resource when data is valid", %{conn: conn} do
    chat = Repo.insert! %Chat{}
    conn = post conn, chat_message_path(conn, :create, chat), message: @valid_attrs
    assert json_response(conn, 201)["data"]["id"]
    assert Repo.get_by(Message, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    chat = Repo.insert! %Chat{}
    conn = post conn, chat_message_path(conn, :create, chat), message: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end
end
