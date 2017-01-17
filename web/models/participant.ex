defmodule Daychat.Participant do
  use Daychat.Web, :model

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

  def set_position(changeset) do
    unless get_change(changeset, :position) do
      chat     = changeset.data.chat
      position = chat.participants_count + 1

      put_change(changeset, :position, position)
    else
      changeset
    end
  end
end
