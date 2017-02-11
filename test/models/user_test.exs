defmodule Daychat.UserTest do
  use Daychat.ModelCase

  alias Daychat.User

  @valid_attrs %{name: "some content", token: "some content"}

  test "changeset with valid attributes" do
    changeset = User.changeset(%User{}, @valid_attrs)
    assert changeset.valid?
  end
end
