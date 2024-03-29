defmodule Daychat.ParticipantController do
  use Daychat.Web, :controller

  alias Daychat.Participant
  alias Daychat.Chat

  plug :find_chat
  plug :check_expiration when action in [:new, :create]
  plug :check_limit when action in [:new, :create]
  plug :verify_recaptcha when action in [:create]
  plug :require_user when action in [:create]

  def new(conn, _params) do
    render(conn, "new.html")
  end

  def create(conn, params) do
    chat = conn.assigns[:chat]
    user = current_user(conn)

    case Participant.insert_with_log!(user, chat, params["name"]) do
      {:ok, {_participant, _user, log}} ->
        Daychat.Endpoint.broadcast!("room:#{chat.token}", "message:new", %{
          name: "BOT",
          token: "BOT",
          body: log.body,
          color: "#000000",
          timestamp: Daychat.MessageView.timestamp(log)
        })

        conn
        |> put_flash(:info, "Participant created successfully.")
        |> redirect(to: chat_path(conn, :show, chat.token))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  defp find_chat(conn, _) do
    chat_id = conn.params["chat_id"]
    query = from c in Chat, preload: [:user]
    chat = Repo.get_by!(query, token: chat_id)

    conn |> assign(:chat, chat)
  end

  defp check_expiration(conn, _) do
    if Daychat.Chat.expired?(conn.assigns[:chat]) do
      conn
      |> redirect(to: expired_chat_path(conn, :index))
      |> halt
    else
      conn
    end
  end

  defp check_limit(conn, _) do
    chat = conn.assigns[:chat]

    if chat.participants_count >= 20 do
      conn
      |> render("maxed.html")
      |> halt
    else
      conn
    end
  end

  defp need_verification?(conn) do
    user = conn.assigns.chat.user
    user != current_user(conn)
  end

  defp verify_recaptcha(conn, _) do
    if need_verification?(conn) do
      response = conn.body_params["g-recaptcha-response"]

      case Recaptcha.verify(response) do
        {:ok, _msg} ->
          conn
        {:error, _msg} ->
          new_participant_path = chat_participant_path(conn, :new, conn.assigns[:chat].token)
          conn
          |> redirect(to: new_participant_path)
          |> halt
      end
    else
      conn
    end
  end
end
