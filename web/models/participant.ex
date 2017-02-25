defmodule Daychat.Participant do
  use Daychat.Web, :model

  @color_palette {
    "#529D24", "#2D63B0", "#DC6D4A",
    "#5A250D", "#D52108", "#6D0C84",
    "#E28F09", "#1E188E", "#7EA413",
    "#6C130E", "#E7E437", "#636E6D",
    "#ECC51E", "#441382", "#DE5000",
    "#87CDE6", "#B5171F", "#B3B568",
    "#C96FAF", "#202711"
  }

  schema "participants" do
    field :position, :integer
    belongs_to :user, Daychat.User
    belongs_to :chat, Daychat.Chat

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:position])
    |> cast_assoc(:user, required: true)
    |> cast_assoc(:chat, required: true)
    |> set_position
  end

  defp set_position(changeset) do
    chat = changeset.data.chat
    unless get_change(changeset, :position) || !Ecto.assoc_loaded?(chat) do
      position = chat.participants_count + 1

      put_change(changeset, :position, position)
    else
      changeset
    end
  end

  def color(participant) do
    color_index = participant.position - 1
    elem(@color_palette, color_index)
  end

  def palette, do: @color_palette

  def insert_with_log!(user, chat, name_update \\ nil) do
    Daychat.Repo.transaction fn ->
      participant =
        %Daychat.Participant{user: user, chat: chat}
        |> Daychat.Participant.changeset
        |> Daychat.Repo.insert!

      user =
        if name_update && String.length(name_update) > 0 do
          user_changeset = Daychat.User.changeset(user, %{name: name_update})
          user = Daychat.Repo.update!(user_changeset)
        else
          user
        end

      log_changeset = ChatLog.new_participant(chat, participant, user)

      log = Daychat.Repo.insert!(log_changeset)

      {participant, user, log}
    end
  end
end
