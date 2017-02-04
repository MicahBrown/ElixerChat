defmodule ChatLog do
  alias Daychat.Message

  def new_participant(chat, participant, user) do
    color = Daychat.Participant.color(participant)
    body = "<strong style='color: #{color};'>#{token(user)}</strong> has joined the chat."
    body |> to_changeset(chat)
  end

  defp to_changeset(body, chat) do
    Message.log_changeset(%Message{chat: chat}, %{body: body})
  end

  defp token(nil),  do: "BOT"
  defp token(user), do: user.token
end