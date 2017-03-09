defmodule Daychat.ParticipantView do
  use Daychat.Web, :view

  def participant_recaptcha_required?(conn, chat) do
    conn.assigns.current_user != chat.user && Recaptcha.verification_required?
  end
end
