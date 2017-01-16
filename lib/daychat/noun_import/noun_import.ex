defmodule NounImport do
  @path File.cwd! <> "/lib/daychat/noun_import/noun_list.txt"

  alias Daychat.Noun

  def import do
    get_words()
    |> Enum.each(fn(word) -> insert_word(word) end)
  end

  defp get_words do
    File.read!(@path)
    |> String.split("\n")
    |> Enum.map(fn(x) -> String.trim(x, "\\n") end)
  end

  defp insert_word(word) do
    Noun.changeset(%Noun{}, %{word: word}) |> Daychat.Repo.insert!
  end
end