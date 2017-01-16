defmodule Daychat.ChatTest do
  use Daychat.ModelCase

  alias Daychat.Chat

  @valid_attrs %{participants_count: 42, token: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Chat.changeset(%Chat{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Chat.changeset(%Chat{}, @invalid_attrs)
    refute changeset.valid?
  end
end
