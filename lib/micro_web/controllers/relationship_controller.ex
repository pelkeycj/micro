defmodule RelationshipController do
  use MicroWeb, :controller

  alias Micro.Accounts
  alias Micro.Accounts.User

  @doc """
    The logged in user follows the given user.
  """
  def follow(conn, %{"user" => user}) do
    case Accounts.create_relationship(%{follower_id: conn.assings[:user_id],
            following_id: :user.id}) do
      {:ok, Relationship} ->
        conn
        |> put_flash(:info, "Following #{user.handle}")
        |> redirect(to: user_path(conn, :show, user))
      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_flash(:error, "Something went wrong.")
        |> redirect(to: user_path(conn, :show, user))
    end
  end

  @doc """
    The logged in user unfollows the given user.
  """
  def unfollow(conn, %{"user" => user}) do
    relationship = Accounts.get_relationship(conn.assigns[:user_id], user)
    {:ok, _relationship} = Accounts.delete_relationship(relationship)

    conn
    |> put_flash(:info, "Unfollowed #{user.handle}")
    |> redirect(to: user_path(conn, :show, user))
  end

  # TODO index

  # TODO
end
