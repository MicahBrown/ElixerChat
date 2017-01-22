defmodule Daychat.MessageView do
  use Daychat.Web, :view

  def render("index.json", %{messages: messages}) do
    %{data: render_many(messages, Daychat.MessageView, "message.json")}
  end

  def render("show.json", %{message: message}) do
    %{data: render_one(message, Daychat.MessageView, "message.json")}
  end

  def render("message.json", %{message: message}) do
    %{id: message.id,
      user_id: message.user_id,
      chat_id: message.chat_id,
      body: message.body}
  end

  def timestamp(message) do
    message.inserted_at
    |> Ecto.DateTime.cast!
    |> DateTimeFormatter.to_datetime
  end
end
