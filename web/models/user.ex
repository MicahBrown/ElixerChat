defmodule Daychat.User do
  use Daychat.Web, :model

  schema "users" do
    field :name, :string
    field :token, :string
    has_many :chats, Daychat.Chat
    has_many :participants, Daychat.Participant

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [])
    |> generate_name
    |> generate_token
    |> validate_required([:name, :token])
    |> validate_length(:name, max: 32)
    |> validate_length(:token, max: 255)
  end

  def new_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [])
  end

  defp generate_name(changeset) do
    unless get_change(changeset, :name) do
      name = NameGenerator.get_unique_for(Daychat.User, :name)

      put_change(changeset, :name, name)
    else
      changeset
    end
  end

  def generate_token(changeset) do
    unless get_change(changeset, :token) do
      put_change(changeset, :token, Tokenizer.generate)
    else
      changeset
    end
  end
end
