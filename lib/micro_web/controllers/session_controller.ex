defmodule MicroWeb.SessionController do
  use MicroWeb, :controller
  alias Micro.Accounts

  

  @doc """
    Logs a user in.
  """
  def login(conn, %{"handle" => handle}) do
    user = Accounts.get_user_by_handle!(handle)

    if user do
      conn
      |> put_session(:user_id, user.id)
      |> put_flash(:info, "Logged in as #{user.name}")
      |> redirect(to: user_path(conn, :index))
    else
      conn
      |> put_session(:user_id, nil)
      |> put_flash(:error, "Handle does not exist.")
      |> redirect(to: user_path(conn, :index))
    end
  end

  @doc """
    Logs a user out.
  """
  def logout(conn, _params) do
    conn
    |> put_session(:user_id, nil)
    |> put_flash(:info, "Logged out.")
    |> redirect(to: user_path(conn, :index))
  end



end
