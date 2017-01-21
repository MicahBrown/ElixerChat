defmodule DateTimeFormatter do
  @months {
    "January", "February", "March",
    "April",   "May",      "June",
    "July",    "August",   "September",
    "October", "November", "December"
  }

  # Time Conversions --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

  def to_time(datetime, :hr12) do
    min   = datetime.min |> with_padding
    hour  = datetime.hour
    hour  = if hour >= 12 do hour - 12 else hour end
    merid = if hour >= 12 do "PM"      else "AM" end

    "#{hour}:#{min} #{merid}"
  end

  def to_time(datetime, :hr24, padded \\ false) do
    min  = datetime.min |> with_padding
    hour = datetime.hour
    hour = if padded do with_padding(hour) else hour end

    "#{hour}:#{min}"
  end

  def to_time(datetime), do: to_time(datetime, :hr12)

  # DateTime Conversions --- --- --- --- --- --- --- --- --- --- --- --- --- ---

  def to_datetime(datetime, :iso8601) do
    date = DateTimeFormatter.to_date(datetime)
    time = DateTimeFormatter.to_time(datetime, :hr24, true)

    date <> " " <> time
  end

  def to_datetime(datetime, :full) do
    date = DateTimeFormatter.to_date(datetime, :full)
    time = DateTimeFormatter.to_time(datetime, :hr12)

    date <> " " <> time
  end

  def to_datetime(datetime, :short) do
    date = DateTimeFormatter.to_date(datetime, :short)
    time = DateTimeFormatter.to_time(datetime, :hr12)

    date <> " " <> time
  end

  def to_datetime(datetime), do: to_datetime(datetime, :iso8601)

  # Date Conversions --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

  def to_date(datetime, :iso8601) do
    day   = datetime.day |> with_padding
    month = datetime.month |> with_padding
    year  = datetime.year

    "#{year}-#{month}-#{day}"
  end

  def to_date(datetime, :full) do
    day   = datetime.day
    year  = datetime.year
    month = datetime.month
    month = elem(@months, month - 1)

    "#{month} #{day}, #{year}"
  end

  def to_date(datetime, :short) do
    day   = datetime.day
    year  = datetime.year
    month = datetime.month
    month = elem(@months, month - 1) |> to_short_month

    "#{month} #{day}, #{year}"
  end

  def to_date(datetime), do: to_date(datetime, :iso8601)

  # Private Methods --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

  defp to_short_month(month) do
    month |> String.slice(0..2)
  end

  defp with_padding(value) do
    value |> Integer.to_string |> String.pad_leading(2, ["0"])
  end
end