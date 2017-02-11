defmodule Daychat.ChatTest do
  use Daychat.ModelCase

  import Daychat.Fixtures

  alias Daychat.Chat

  @valid_attrs %{}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    user = fixture!(:user)
    changeset = Chat.changeset(%Chat{user: user}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Chat.changeset(%Chat{}, @invalid_attrs)
    refute changeset.valid?
  end

  test "expiration check returns false if chat inserted within a day" do
    day_in_seconds = (24 * 60 * 60) - (5 * 60)
    time_in_seconds = Ecto.DateTime.utc |> Ecto.DateTime.to_erl |> :calendar.datetime_to_gregorian_seconds
    within_day_datetime = (time_in_seconds - day_in_seconds) |> :calendar.gregorian_seconds_to_datetime |> Ecto.DateTime.from_erl

    chat = fixture!(:chat)
    changeset = Chat.changeset(chat) |> put_change(:inserted_at, within_day_datetime)
    expired_chat = Repo.update!(changeset)

    refute Chat.expired?(expired_chat)
  end

  test "expiration check returns true if chat inserted more than a day ago" do
    day_in_seconds = (24 * 60 * 60) + 1
    time_in_seconds = Ecto.DateTime.utc |> Ecto.DateTime.to_erl |> :calendar.datetime_to_gregorian_seconds
    day_ago_datetime = (time_in_seconds - day_in_seconds) |> :calendar.gregorian_seconds_to_datetime |> Ecto.DateTime.from_erl

    chat = fixture!(:chat)
    changeset = Chat.changeset(chat) |> put_change(:inserted_at, day_ago_datetime)
    expired_chat = Repo.update!(changeset)

    assert Chat.expired?(expired_chat)
  end
end
