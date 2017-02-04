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
    |> cast_assoc(:chat, required: true)
    |> cast_assoc(:user, required: true)
    |> validate_required([:body])
  end

  def log_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:body])
    |> cast_assoc(:chat, required: true)
    |> validate_required([:body])
  end

  def new_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [])
  end
end
