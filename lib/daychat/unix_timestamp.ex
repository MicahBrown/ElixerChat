defmodule UnixTimestamp do
  epoch = {{1970, 1, 1}, {0, 0, 0}}
  @epoch :calendar.datetime_to_gregorian_seconds(epoch)

  def from(timestamp) do
    timestamp + @epoch
    |> :calendar.gregorian_seconds_to_datetime
    |> Ecto.DateTime.from_erl
  end

  def to(datetime) do
    greg_sec =
      datetime
      |> Ecto.DateTime.to_erl
      |> :calendar.datetime_to_gregorian_seconds

    greg_sec - @epoch
  end
end
