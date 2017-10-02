defmodule MicroWeb.RelationshipController do
  use MicroWeb, :controller

  alias Micro.Accounts
  alias Micro.Accounts.User

  @doc """
    The logged in user follows the given user.
  """
  def follow(conn, %{"current" => current, "user" => user}) do
    user = Accounts.get_user!(user)
    current = Accounts.get_user!(current)
    case Accounts.create_relationship(%{follower_id: current.id,
            following_id: user.id}) do
      {:ok, _relationship} ->
        conn
        |> put_flash(:info, "Following #{user.handle}")
        |> redirect(to: user_path(conn, :show, user))
      {:error, _changeset} ->
        conn
        |> put_flash(:error, "Something went wrong.")
        |> redirect(to: user_path(conn, :show, user))
    end
  end

  @doc """
    The logged in user unfollows the given user.
  """
  def unfollow(conn, %{"current" => current, "user" => user}) do

    relationship = Accounts.get_relationship(current, user)
    {:ok, _relationship} = Accounts.delete_relationship(relationship)

    user = Accounts.get_user!(user)
    conn
    |> put_flash(:info, "Unfollowed #{user.handle}")
    |> redirect(to: user_path(conn, :show, user))
  end


  # TODO index based on param (followers, followings)?
end
