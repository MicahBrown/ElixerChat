defmodule Daychat.Noun do
  use Daychat.Web, :model

  schema "nouns" do
    field :word, :string
    field :weight, :integer

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:word, :weight])
    |> validate_required([:word])
  end
end
