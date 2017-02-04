defmodule Daychat.ChatView do
  use Daychat.Web, :view

  def deadline(chat) do
    chat.inserted_at
    |> Ecto.DateTime.cast!
    |> Ecto.DateTime.to_erl
    |> :calendar.datetime_to_gregorian_seconds
    |> add_day
    |> :calendar.gregorian_seconds_to_datetime
    |> Ecto.DateTime.from_erl
    |> DateTimeFormatter.to_datetime
  end

  def add_day(datetime) do
    datetime + (60 * 60 * 24)
  end
end
