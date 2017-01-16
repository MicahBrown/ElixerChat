defmodule Authentication do
  import Plug.Conn

  def require_user(conn, params) do
    conn =
      unless current_user(conn) do
        changeset = Daychat.User.changeset(%Daychat.User{})
        user = Daychat.Repo.insert!(changeset)

        put_current_user(conn, user)
      else
        conn
      end

    authenticate(conn, params)
  end

  def current_user(conn) do
    conn.assigns["current_user"] || get_current_user(conn)
  end

  def authenticate(conn, _) do
    if user = get_current_user(conn) do
      assign_current_user(conn, user)
    else
      halt(conn)
    end
  end

  defp get_current_user(conn) do
    if id = get_session(conn, :user_id) do
      Daychat.Repo.get_by(Daychat.User, token: id)
    else
      nil
    end
  end

  defp put_current_user(conn, user) do
    put_session(conn, :user_id, user.token)
  end

  defp assign_current_user(conn, user) do
    assign(conn, :current_user, user)
  end
end