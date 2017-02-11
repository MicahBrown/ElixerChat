defmodule Daychat.ParticipantTest do
  use Daychat.ModelCase

  import Daychat.Fixtures

  alias Daychat.Participant

  @valid_attrs %{position: 42}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    chat = fixture!(:chat)
    user = fixture!(:user)
    changeset = Participant.changeset(%Participant{chat: chat, user: user}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Participant.changeset(%Participant{}, @invalid_attrs)
    refute changeset.valid?
  end

  test "retrieving a color" do
    user = fixture!(:user)
    chat = fixture!(:chat) |> add_participants(5)
    participant = Participant.changeset(%Participant{chat: chat, user: user}) |> Repo.insert!
    position = participant.position

    assert Participant.color(participant) == elem(Participant.palette, position)
  end
end
