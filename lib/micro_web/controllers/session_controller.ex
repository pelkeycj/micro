defmodule MicroWeb.SessionController do
  use MicroWeb, :controller
  alias Micro.Accounts

  @doc """
    Logs a user in.
  """
  def login(conn, %{"handle" => handle, "password" => password}) do
    user = Accounts.get_and_auth_user(handle, password)

    if user do
      conn
      |> put_session(:user_id, user.id)
      |> redirect(to: user_path(conn, :show, user))
    else
      conn
      |> put_session(:user_id, nil)
      |> put_flash(:error, "That account doesn't exist.")
      |> redirect(to: page_path(conn, :index))
    end
  end

  @doc """
    Logs a user out.
  """
  def logout(conn, _params) do
    conn
    |> put_session(:user_id, nil)
    |> redirect(to: page_path(conn, :index))
  end
end
