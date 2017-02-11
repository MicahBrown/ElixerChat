defmodule Daychat.Fixtures do
  alias Daychat.Repo
  alias Daychat.User
  alias Daychat.Chat
  alias Daychat.Participant

  def fixture(name, attrs \\ %{})
  def fixture(:user, attrs) do
    User.changeset(%User{}, attrs)
  end

  def fixture(:chat, attrs) do
    user = fixture!(:user)
    Chat.changeset(%Chat{user: user}, attrs)
  end

  def fixture(:participant, attrs) do
    user = fixture!(:user)
    chat = fixture!(:chat)
    Participant.changeset(%Participant{user: user, chat: chat}, attrs)
  end

  def fixture!(name, attrs \\ %{}) do
    Repo.insert! fixture(name, attrs)
  end
end