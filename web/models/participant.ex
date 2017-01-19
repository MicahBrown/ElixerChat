defmodule Daychat.Participant do
  use Daychat.Web, :model

  @color_palette {
    '#ECC51E', '#441382', '#DE5000', # orange,         yellow,       purple
    '#87CDE6', '#B5171F', '#B3B568', # light blue,     red,          buff
    '#636E6D', '#529D24', '#C96FAF', # gray,           green,        pink
    '#2D63B0', '#DC6D4A', '#1E188E', # blue,           peach,        violet
    '#1E188E', '#6D0C84', '#E7E437', # light orange,   light purple, light yellow
    '#6C130E', '#7EA413', '#5A250D', # reddish brown,  light green,  brown
    '#D52108', '#202711'             # reddish orange, olive green
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

  def new_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [])
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

  def color(participant) do
    color_index = participant.position  - 1
    elem(@color_palette, color_index)
  end
end
