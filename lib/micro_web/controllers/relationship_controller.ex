defmodule MicroWeb.RelationshipController do
  use MicroWeb, :controller

  alias Micro.{Accounts, Blog}
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
        |> redirect(to: user_path(conn, :show, user))
      {:error, _changeset} ->
        conn
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
    |> redirect(to: user_path(conn, :show, user))
  end


  @doc """
    Displays views dependent on relationships.
    Views include: follower list, following list, home page,
    and explore posts

  """
  def index(conn, %{"view" => view, "user" => user}) do
    case view do
      :followers ->
        followers = Accounts.get_followers(user.id)
        render(conn, "index.html", header: "followers", users: followers)

      :followings ->
        followings = Accounts.get_followings(user.id)
        render(conn, "index.html", header: "following", users: followings)

      :home ->
        followings = Accounts.get_followings(user.id)
        posts = Blog.get_posts_for_users(followings)
        render(conn, "home.html", posts: posts)


      #:explore_posts ->

      #:explore_users ->

      _->
        conn
        |> redirect(to: user_path(conn, :show, user))

    end
  end
end
