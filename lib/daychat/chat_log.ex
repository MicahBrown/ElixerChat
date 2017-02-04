defmodule ChatLog do
  alias Daychat.Message

  def new_participant(chat, _participant) do
    body = "This is just a test message"
    body |> to_changeset(chat)
  end

  defp to_changeset(body, chat) do
    Message.log_changeset(%Message{chat: chat}, %{body: body})
  end
end