defmodule Daychat.Message do
  use Daychat.Web, :model

  schema "messages" do
    field :body, :string
    belongs_to :user, Daychat.User
    belongs_to :chat, Daychat.Chat

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:body])
    |> validate_required([:body])
  end

  def new_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [])
  end
end
