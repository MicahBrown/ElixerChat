defmodule Recaptcha do
  def verify(resp) do
    unless verification_required?() do
      verified_response() # always pass verification in test env.
    else
      get_api_response(resp) |> resolve_api_response
    end
  end

  def key do
    System.get_env("RECAPTCHA_KEY")
  end

  def secret do
    System.get_env("RECAPTCHA_SECRET")
  end

  def verification_required? do
    System.get_env("REQUIRE_VERIFICATION") == "true"
  end

  defp url(resp) do
    "https://www.google.com/recaptcha/api/siteverify?response=#{resp}&secret=#{secret()}"
  end

  defp get_api_response(resp) do
    api_resp =
      resp
      |> url
      |> HTTPoison.get!

    parse_api_response(api_resp.body)
  end

  defp parse_api_response(api_resp) do
    api_resp |> Poison.Parser.parse!
  end

  defp resolve_api_response(%{"success" => verified}) do
    case verified do
      true ->
        verified_response()
      false ->
        invalid_response()
      _ ->
        invalid_response()
    end
  end
  defp resolve_api_response(_api_resp), do: invalid_response()

  defp invalid_response, do: {:error, "invalid response"}
  defp verified_response, do: {:ok, "verified"}
end