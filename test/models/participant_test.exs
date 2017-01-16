defmodule Daychat.ParticipantTest do
  use Daychat.ModelCase

  alias Daychat.Participant

  @valid_attrs %{position: 42}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Participant.changeset(%Participant{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Participant.changeset(%Participant{}, @invalid_attrs)
    refute changeset.valid?
  end
end
