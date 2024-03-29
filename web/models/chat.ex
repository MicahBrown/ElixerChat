defmodule Daychat.Chat do
  use Daychat.Web, :model

  schema "chats" do
    field :token, :string
    field :auth_key, :string
    field :participants_count, :integer
    belongs_to :user, Daychat.User
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
    |> cast_assoc(:user, required: true)
    |> generate_name
    |> generate_token
    |> validate_required([:token, :auth_key])
    |> validate_length(:token, max: 32)
    |> validate_length(:auth_key, max: 128)
    |> validate_inclusion(:participants_count, 0..20)
    |> set_participant_count
  end

  defp generate_name(changeset) do
    unless get_change(changeset, :token) do
      token = TokenGenerator.get_unique(Daychat.Chat)
      put_change(changeset, :token, token)
    else
      changeset
    end
  end

  defp set_participant_count(changeset) do
    unless get_change(changeset, :participants_count) do
      put_change(changeset, :participants_count, 0)
    else
      changeset
    end
  end

  defp generate_token(changeset) do
    unless get_change(changeset, :auth_key) do
      auth_key = AuthKeyGenerator.get_unique(Daychat.Chat)
      put_change(changeset, :auth_key, auth_key)
    else
      changeset
    end
  end

  def expired?(chat) do
    Ecto.DateTime.compare(Ecto.DateTime.utc, expiration(chat)) == :gt
  end

  def expiration(chat) do
    chat.inserted_at
    |> Ecto.DateTime.cast!
    |> Ecto.DateTime.to_erl
    |> :calendar.datetime_to_gregorian_seconds
    |> add_day
    |> :calendar.gregorian_seconds_to_datetime
    |> Ecto.DateTime.from_erl
  end

  defp add_day(datetime), do: datetime + (60 * 60 * 24)
end
