defmodule NameGenerator do
  import Ecto.Query

  alias Daychat.Noun

  @colors [
    "cyan", "black", "blue", "bronze", "brown",
    "gold", "gray", "green", "maroon", "navy",
    "orange", "pink", "puce", "purple", "red",
    "silver", "teal", "white", "yellow"
  ]

  def get_unique_for(mod_name, column) do
    comp = generate()
    name = compile(comp)

    if length(existing(mod_name, column, name)) > 0 do
      get_unique_for(mod_name, column)
    else
      increment_weight!(comp[:noun])
      name
    end
  end

  def generate do
    components()
    |> get_number
    |> get_color
    |> get_noun
  end

  def compile(comp) do
    ""
    |> append_number(comp)
    |> append_color(comp)
    |> append_noun(comp)
  end

  defp append_number(str, comp) do
    number = comp[:number]

    str <> number
  end

  defp append_color(str, comp) do
    color = comp[:color] |> String.capitalize

    str <> color
  end

  defp append_noun(str, comp) do
    noun = comp[:noun].word |> String.capitalize |> Inflex.pluralize

    str <> noun
  end

  defp get_number(comp) do
    number = :rand.uniform(10000) |> Integer.to_string
    %{comp | number: number}
  end

  defp get_color(comp) do
    color = Enum.random(@colors) |> String.capitalize
    %{comp | color: color}
  end

  defp get_noun(comp) do
    weight_query = from noun in Noun,
      select: max(noun.weight)
    max_weight = hd Daychat.Repo.all(weight_query)

    noun_query = from noun in Noun,
      where: noun.weight == ^max_weight,
      order_by: fragment("RANDOM()"),
      limit: 1
    noun = hd Daychat.Repo.all(noun_query)

    %{comp | noun: noun}
  end

  defp components do
    %{number: nil, color: nil, noun: nil}
  end

  defp existing(mod_name, column, name) do
    query = from object in mod_name,
      where: field(object, ^column) == ^name,
      limit: 1

    Daychat.Repo.all(query)
  end

  defp increment_weight!(noun) do
    changeset = Noun.changeset(noun, %{weight: 0})
    Daychat.Repo.update!(changeset)
  end
end