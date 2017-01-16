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
    |> validate_required([:position])
  end
end
