defmodule Tokenizer do
  @size 11
  @charset "123456789abcdefghijkmnopqrstuvwxyzABCDEFGHJKLMNPQRSTUVWXYZ" |> String.codepoints # Base58

  def generate do
    "" |> make_token(@size)
  end

  defp make_token(token, n) when n <= 0, do: token
  defp make_token(token, n) do
    Enum.random(@charset) <> token
    |> make_token(n - 1)
  end
end