defmodule Authentication do
  import Plug.Conn

  def require_user(conn, _) do
    unless current_user(conn) do
      changeset = Daychat.User.changeset(%Daychat.User{})
      user      = Daychat.Repo.insert!(changeset)

      put_current_user(conn, user) |> assign_current_user(user)
    else
      conn
    end
  end

  def current_user(conn) do
    conn.assigns.current_user
  end

  def set_current_user(conn, _) do
    id   = get_session(conn, :user_id)
    user = if id do Daychat.Repo.get_by(Daychat.User, auth_key: id) else nil end

    assign_current_user(conn, user)
  end

  defp assign_current_user(conn, user) do
    assign(conn, :current_user, user)
  end

  defp put_current_user(conn, user) do
    put_session(conn, :user_id, user.auth_key)
  end
end