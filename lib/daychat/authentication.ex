defmodule Authentication do
  import Plug.Conn

  def require_user(auth_conn, params) do
    auth_conn =
      unless current_user(auth_conn) do
        changeset = Daychat.User.changeset(%Daychat.User{})
        user = Daychat.Repo.insert!(changeset)

        set_current_user(auth_conn, user)
      else
        auth_conn
      end

    authenticate(auth_conn, params)
  end

  def current_user(auth_conn) do
    if id = get_session(auth_conn, :user_id) do
      Daychat.Repo.get_by(Daychat.User, token: id)
    else
      nil
    end
  end

  def authenticate(auth_conn, _) do
    if user = current_user(auth_conn) do
      assign(auth_conn, :current_user, user)
    else
      halt(auth_conn)
    end
  end

  defp set_current_user(auth_conn, user) do
    put_session(auth_conn, :user_id, user.token)
  end
end