defmodule Daychat.NounTest do
  use Daychat.ModelCase

  alias Daychat.Noun

  @valid_attrs %{weight: 42, word: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Noun.changeset(%Noun{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Noun.changeset(%Noun{}, @invalid_attrs)
    refute changeset.valid?
  end
end
