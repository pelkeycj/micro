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
  def index(conn, %{"view" => view, "user" => user_id}) do
    user = Accounts.get_user!(user_id)
    case view do
      "followers" ->
        followers = Accounts.get_followers(user_id)
        render(conn, "index.html", header: "followers", users: followers)

      "followings" ->
        followings = Accounts.get_followings(user_id)
        render(conn, "index.html", header: "following", users: followings)

      "home" ->
        followings = Accounts.get_followings(user_id) ++ [user]
        posts = Blog.get_posts_for_users(followings)
        posts = Blog.sort_posts_by_time(posts)
        render(conn, "home.html", conn: conn, posts: posts)


      "explore_users" ->
        strangers = Accounts.get_strangers(user_id)
        strangers = Enum.shuffle(strangers)
        render(conn, "explore_users.html", conn: conn, users: strangers, current_user: user)

      "explore_posts" ->
        strangers = Accounts.get_strangers(user_id)
        posts = Blog.get_posts_for_users(strangers)
        posts = Enum.shuffle(posts)
        render(conn, "explore_posts.html", conn: conn, posts: posts, current_user: user)

      _->
        conn
        |> redirect(to: user_path(conn, :show, user_id))
    end
  end

  def index(conn, %{"view" => view}) do
    case view do
      "explore_posts" ->
        users = Accounts.list_users()
        posts = Blog.get_posts_for_users(users)
        posts = Enum.shuffle(posts)
        render(conn, "explore_posts.html", conn: conn, posts: posts)

      "explore_users" ->
        users = Accounts.list_users()
        users = Enum.shuffle(users)
        render(conn, "explore_users.html", conn: conn, users: users)

      _->
        conn
        |> redirect(to: user_path(conn, :index))
    end
  end

end
