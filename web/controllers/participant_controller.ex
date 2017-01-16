defmodule Daychat.ParticipantController do
  use Daychat.Web, :controller

  alias Daychat.Participant

  # def index(conn, _params) do
  #   participants = Repo.all(Participant)
  #   render(conn, "index.html", participants: participants)
  # end

  def new(conn, _params) do
    changeset = Participant.changeset(%Participant{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"participant" => participant_params}) do
    changeset = Participant.changeset(%Participant{}, participant_params)

    case Repo.insert(changeset) do
      {:ok, _participant} ->
        conn
        |> put_flash(:info, "Participant created successfully.")
        |> redirect(to: chat_participant_path(conn, :new))
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
end
