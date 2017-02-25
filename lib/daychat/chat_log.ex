defmodule ChatLog do
  alias Daychat.Message

  def new_participant(chat, participant, user) do
    color = Daychat.Participant.color(participant)
    body = "<strong style='color: #{color};'>#{name(user)}</strong> has joined the chat."
    body |> to_changeset(chat)
  end

  defp to_changeset(body, chat) do
    Message.log_changeset(%Message{chat: chat}, %{body: body})
  end

  defp name(nil),  do: "BOT"
  defp name(user), do: user.name
end