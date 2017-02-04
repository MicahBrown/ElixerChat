defmodule Keygen do
  @size 11
  @charset "123456789abcdefghijkmnopqrstuvwxyzABCDEFGHJKLMNPQRSTUVWXYZ" |> String.codepoints # Base58

  def generate do
    "" |> make_key(@size)
  end

  defp make_key(token, n) when n <= 0, do: token
  defp make_key(token, n) do
    Enum.random(@charset) <> token
    |> make_key(n - 1)
  end
end