defmodule Daychat.MessageController do
  use Daychat.Web, :controller

  alias Daychat.Message

  plug :find_chat
  plug :check_expiration

  def create(conn, %{"message" => message_params}) do
    changeset = Message.changeset(%Message{user: current_user(conn), chat: conn.assigns[:chat]}, message_params)

    case Repo.insert(changeset) do
      {:ok, message} ->
        conn
        |> put_status(:created)
        |> put_resp_header("location", chat_path(conn, :show, conn.assigns[:chat]))
        |> render("show.json", message: message)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(Daychat.ChangesetView, "error.json", changeset: changeset)
    end
  end

  defp find_chat(conn, _) do
    chat_id = conn.params["chat_id"]
    chat = Repo.get_by!(Daychat.Chat, token: chat_id)

    conn |> assign(:chat, chat)
  end

  defp check_expiration(conn, _) do
    if Daychat.Chat.expired?(conn.assigns[:chat]) do
      halt(conn)
    else
      conn
    end
  end
end
