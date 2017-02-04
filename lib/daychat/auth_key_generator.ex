defmodule AuthKeyGenerator do
  import Ecto.Query

  @size 11
  @charset "123456789abcdefghijkmnopqrstuvwxyzABCDEFGHJKLMNPQRSTUVWXYZ" |> String.codepoints # Base58

  def generate(), do: "" |> make_key(@size)

  def  get_unique(model, column \\ :auth_key), do: find_unique({model, column}, generate())
  defp find_unique(target, auth_key), do: find_unique(target, auth_key, existing(target, auth_key))
  defp find_unique({model, column}, _auth_key, existing) when length(existing) > 0, do: get_unique(model, column)
  defp find_unique(_target, auth_key, existing) when length(existing) <= 0, do: auth_key


  defp make_key(auth_key, n) when n <= 0, do: auth_key
  defp make_key(auth_key, n) do
    Enum.random(@charset) <> auth_key
    |> make_key(n - 1)
  end

   defp existing({model, column}, auth_key) do
    query = from object in model,
      where: field(object, ^column) == ^auth_key,
      limit: 1

    Daychat.Repo.all(query)
  end
end