defmodule Daychat.MessageTest do
  use Daychat.ModelCase

  import Daychat.Fixtures

  alias Daychat.Message

  @valid_attrs %{body: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    user = fixture!(:user)
    chat = fixture!(:chat)

    changeset = Message.changeset(%Message{user: user, chat: chat}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Message.changeset(%Message{}, @invalid_attrs)
    refute changeset.valid?
  end

  test "log changeset with valid attributes" do
    chat = fixture!(:chat)

    log_changeset = Message.log_changeset(%Message{chat: chat}, @valid_attrs)
    assert log_changeset.valid?
  end

  test "log changeset with invalid attributes" do
    log_changeset = Message.log_changeset(%Message{}, @invalid_attrs)
    refute log_changeset.valid?
  end
end
