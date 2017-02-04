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

  def display_body(message) do
    message.body |> Phoenix.HTML.Format.text_to_html
  end

  def user_token(message), do: token(message.user)
  defp token(nil), do: "BOT"
  defp token(user), do: user.token

  def participant_color(message, participants) do
    participant = Enum.find(participants, fn(p) -> p.user_id == message.user_id end)
    color(participant)
  end
  defp color(nil), do: "#000000"
  defp color(participant), do: Daychat.Participant.color(participant)

  def author(message, participants) do
    content = Phoenix.HTML.Tag.content_tag(:i, "", class: "fa fa-user-circle")
    content = raw("<i class='fa fa-user-circle'></i> #{user_token(message)}")
    Phoenix.HTML.Tag.content_tag(:span, content, style: "color: #{participant_color(message, participants)}")
  end
end
