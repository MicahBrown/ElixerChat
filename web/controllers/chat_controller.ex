defmodule Daychat.ChatController do
  use Daychat.Web, :controller

  alias Daychat.Chat
  alias Daychat.Participant

  plug :find_chat when action in [:show]
  plug :verify_recaptcha when action in [:create]
  plug :require_user when action in [:create, :show]
  plug :require_participant when action in [:show]

  # def index(conn, _params) do
  #   chats = Repo.all(Chat)
  #   render(conn, "index.html", chats: chats)
  # end

  def new(conn, _) do
    redirect(conn, to: root_path(conn, :index))
  end

  def create(conn, _) do
    changeset = Chat.changeset(%Chat{user: current_user(conn)})

    case Repo.insert(changeset) do
      {:ok, chat} ->
        participant = Ecto.build_assoc(chat, :participants, user: current_user(conn), chat: chat)
        Repo.insert(participant)

        conn
        |> put_flash(:info, "Chat created successfully.")
        |> redirect(to: chat_path(conn, :show, chat.name()))
      {:error, _changeset} ->
        redirect(conn, to: root_path(conn, :index))
    end
  end

  def show(conn, %{"id" => _name}) do
    chat = conn.assigns[:chat]
    message_changeset = Daychat.Message.new_changeset(%Daychat.Message{})
    participants = Repo.all from p in Participant, where: [chat_id: ^chat.id]
    messages = Repo.all from m in Daychat.Message,
                where: [chat_id: ^chat.id],
                preload: [:user]

    conn
    |> assign(:message_changeset, message_changeset)
    |> assign(:messages, messages)
    |> assign(:participants, participants)
    |> render("show.html", chat: chat)
  end

  # def edit(conn, %{"id" => id}) do
  #   chat = Repo.get!(Chat, id)
  #   changeset = Chat.changeset(chat)
  #   render(conn, "edit.html", chat: chat, changeset: changeset)
  # end

  # def update(conn, %{"id" => id, "chat" => chat_params}) do
  #   chat = Repo.get!(Chat, id)
  #   changeset = Chat.changeset(chat, chat_params)

  #   case Repo.update(changeset) do
  #     {:ok, chat} ->
  #       conn
  #       |> put_flash(:info, "Chat updated successfully.")
  #       |> redirect(to: chat_path(conn, :show, chat))
  #     {:error, changeset} ->
  #       render(conn, "edit.html", chat: chat, changeset: changeset)
  #   end
  # end

  # def delete(conn, %{"id" => id}) do
  #   chat = Repo.get!(Chat, id)

  #   # Here we use delete! (with a bang) because we expect
  #   # it to always work (and if it does not, it will raise).
  #   Repo.delete!(chat)

  #   conn
  #   |> put_flash(:info, "Chat deleted successfully.")
  #   |> redirect(to: chat_path(conn, :index))
  # end

  defp require_participant(conn, _) do
    participants = Repo.all(Ecto.assoc(current_user(conn), :participants))

    conn =
      unless part_of_chat?(conn, participants) do
        new_participant_path = chat_participant_path(conn, :new, conn.assigns[:chat].name)

        conn
        |> redirect(to: new_participant_path)
        |> halt
      else
        conn
      end

    conn
  end

  defp part_of_chat?(_conn, []), do: false
  defp part_of_chat?(conn, participants) do
    part_chat_ids = Enum.map(participants, fn(x) -> x.chat_id end)
    chat_id = conn.assigns.chat.id

    Enum.member?(part_chat_ids, chat_id)
  end

  defp find_chat(conn, _) do
    chat_id = conn.params["id"]
    chat = Repo.get_by!(Chat, name: chat_id)

    conn |> assign(:chat, chat)
  end

  defp verify_recaptcha(conn, _) do
    response = conn.body_params["g-recaptcha-response"]

    case Recaptcha.verify(response) do
      {:ok, _msg} ->
        conn
      {:error, _msg} ->
        conn
        |> redirect(to: root_path(conn, :index))
        |> halt
    end
  end
end
