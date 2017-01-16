defmodule Daychat.ChatController do
  use Daychat.Web, :controller

  alias Daychat.Chat

  plug :require_user when action in [:create, :show]

  # def index(conn, _params) do
  #   chats = Repo.all(Chat)
  #   render(conn, "index.html", chats: chats)
  # end

  def new(conn, _params) do
    changeset = Chat.new_changeset(%Chat{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"chat" => chat_params}) do
    changeset = Chat.changeset(%Chat{user: current_user(conn)}, chat_params)

    case Repo.insert(changeset) do
      {:ok, chat} ->
        conn
        |> put_flash(:info, "Chat created successfully.")
        |> redirect(to: chat_path(conn, :show, chat.name()))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => name}) do
    chat = Repo.get_by!(Chat, name: name)
    render(conn, "show.html", chat: chat)
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
end
