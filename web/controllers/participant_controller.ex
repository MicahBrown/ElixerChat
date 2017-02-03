defmodule Daychat.ParticipantController do
  use Daychat.Web, :controller

  alias Daychat.Participant
  alias Daychat.Chat

  plug :find_chat
  plug :verify_recaptcha when action in [:create]
  plug :require_user when action in [:create]

  # def index(conn, _params) do
  #   participants = Repo.all(Participant)
  #   render(conn, "index.html", participants: participants)
  # end

  def new(conn, _params) do
    changeset = Participant.new_changeset(%Participant{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, _params) do
    changeset = Participant.changeset(%Participant{user: current_user(conn), chat: conn.assigns[:chat]})

    case Repo.insert(changeset) do
      {:ok, _participant} ->
        conn
        |> put_flash(:info, "Participant created successfully.")
        |> redirect(to: chat_path(conn, :show, conn.assigns[:chat].name))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  # def show(conn, %{"id" => id}) do
  #   participant = Repo.get!(Participant, id)
  #   render(conn, "show.html", participant: participant)
  # end

  # def edit(conn, %{"id" => id}) do
  #   participant = Repo.get!(Participant, id)
  #   changeset = Participant.changeset(participant)
  #   render(conn, "edit.html", participant: participant, changeset: changeset)
  # end

  # def update(conn, %{"id" => id, "participant" => participant_params}) do
  #   participant = Repo.get!(Participant, id)
  #   changeset = Participant.changeset(participant, participant_params)

  #   case Repo.update(changeset) do
  #     {:ok, participant} ->
  #       conn
  #       |> put_flash(:info, "Participant updated successfully.")
  #       |> redirect(to: participant_path(conn, :show, participant))
  #     {:error, changeset} ->
  #       render(conn, "edit.html", participant: participant, changeset: changeset)
  #   end
  # end

  # def delete(conn, %{"id" => id}) do
  #   participant = Repo.get!(Participant, id)

  #   # Here we use delete! (with a bang) because we expect
  #   # it to always work (and if it does not, it will raise).
  #   Repo.delete!(participant)

  #   conn
  #   |> put_flash(:info, "Participant deleted successfully.")
  #   |> redirect(to: participant_path(conn, :index))
  # end

  defp find_chat(conn, _) do
    chat_id = conn.params["chat_id"]
    chat = Repo.get_by!(Chat, name: chat_id)

    conn |> assign(:chat, chat)
  end

  defp verify_recaptcha(conn, _) do
    response = conn.body_params["g-recaptcha-response"]

    case Recaptcha.verify(response) do
      {:ok, _msg} ->
        conn
      {:error, _msg} ->
        new_participant_path = chat_participant_path(conn, :new, conn.assigns[:chat].name)
        conn
        |> redirect(to: new_participant_path)
        |> halt
    end
  end
end
