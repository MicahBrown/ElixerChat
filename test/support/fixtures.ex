defmodule Daychat.Fixtures do
  alias Daychat.Repo
  alias Daychat.Chat

  def fixture(:chat) do
    %Chat{
      token: AuthKeyGenerator.generate,
      auth_key: AuthKeyGenerator.generate
    }
  end

  def fixture!(name) do
    Repo.insert! fixture(name)
  end
end