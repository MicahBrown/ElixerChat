defmodule Daychat.User do
  use Daychat.Web, :model

  schema "users" do
    field :token, :string
    field :auth_key, :string
    has_many :chats, Daychat.Chat
    has_many :participants, Daychat.Participant
    has_many :messages, Daychat.Message

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [])
    |> generate_token
    |> generate_auth_key
    |> validate_required([:token, :auth_key])
    |> validate_length(:token, max: 32)
    |> validate_length(:auth_key, max: 255)
  end

  def new_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [])
  end

  defp generate_token(changeset) do
    unless get_change(changeset, :token) do
      token = TokenGenerator.get_unique_for(Daychat.User, :token)

      put_change(changeset, :token, token)
    else
      changeset
    end
  end

  def generate_auth_key(changeset) do
    unless get_change(changeset, :auth_key) do
      put_change(changeset, :auth_key, AuthKeyGenerator.generate)
    else
      changeset
    end
  end
end
