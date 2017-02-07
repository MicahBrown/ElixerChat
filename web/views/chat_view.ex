defmodule Daychat.ChatView do
  use Daychat.Web, :view

  def deadline(chat), do: Daychat.Chat.expiration(chat) |> DateTimeFormatter.to_datetime
end
