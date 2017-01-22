defmodule Daychat.RoomChannel do
  use Daychat.Web, :channel
  alias Daychat.Presence
  alias Daychat.Participant
  alias Daychat.Chat

  def join("room:" <> _id, %{"token" => token}, socket) do
    case Phoenix.Token.verify(socket, "chat_token", token) do
      {:ok, chat_token} ->
        chat = Daychat.Repo.get_by!(Chat, token: chat_token)
        part = load_participant(socket, chat)

        if part do
          socket =
            socket
            |> assign(:chat, chat)
            |> assign(:color, Participant.color(part))

          send self(), :after_join

          {:ok, socket}
        else
          :error
        end
      {:error, _} ->
        :error
    end
  end

  def join(_room, _params, _socket), do: {:error, %{reason: "invalid room"}}


  def handle_info(:after_join, socket) do
    Presence.track(socket, socket.assigns.user_name, %{
      online_at: :os.system_time(:milli_seconds)
    })
    push socket, "presence_state", Presence.list(socket)
    {:noreply, socket}
  end

  def handle_in("message:new", body, socket) do
    message =
      %Daychat.Message{user: socket.assigns.user, chat: socket.assigns.chat}
      |> Daychat.Message.changeset(%{body: body})
      |> Daychat.Repo.insert!

    broadcast! socket, "message:new", %{
      user: socket.assigns.user_name,
      body: message.body,
      color: socket.assigns.color,
      timestamp: Daychat.MessageView.timestamp(message)
    }
    {:noreply, socket}
  end

  defp load_participant(socket, chat) do
    user = socket.assigns.user
    Daychat.Repo.get_by(Participant, chat_id: chat.id, user_id: user.id)
  end
end
