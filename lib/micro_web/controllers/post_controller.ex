defmodule MicroWeb.PostController do
  use MicroWeb, :controller

  alias Micro.Blog
  alias Micro.Blog.Post

  plug :assign_user
  plug :authorize_user when action in [:new, :create, :update, :edit, :delete]

  def index(conn, _params) do
    user = conn.assigns[:user]
    if user do
      posts = Blog.list_posts(user)
      render(conn, "index.html", posts: posts)
    else
      conn
      |> put_flash(:error, "Invalid user")
      |> redirect(to: user_path(conn, :index))
    end

  end

  def new(conn, _params) do
    changeset =
      conn.assigns[:user]
      |> Ecto.build_assoc(:posts)
      |> Blog.change_post()
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"post" => post_params}) do
    case Blog.create_post(conn.assigns[:user], post_params) do
      {:ok, post} ->
        # broadcast post to all follower channels
        Micro.Accounts.broadcast_post_to_followers(conn.assigns[:user].id, post)
        conn
        |> redirect(to: user_post_path(conn, :show, conn.assigns[:user], post))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  # used in posting via channels
  def create(%{"user_id" => user_id, "post" => post_params}) do
    user = Micro.Accounts.get_user!(user_id)
    case Blog.create_post(user, post_params) do
      {:ok, post} ->
        Micro.Accounts.broadcast_post_to_followers(user.id, post)
        {:ok, post}
      {:error, _changeset} ->
        {:error, %{reason: "Invalid attributes"}}
    end
  end

  def show(conn, %{"id" => id}) do
    post = Blog.get_post!(conn.assigns[:user], id)
    render(conn, "show.html", post: post)
  end

  def edit(conn, %{"id" => id}) do
    post = Blog.get_post!(conn.assigns[:user], id)
    changeset = Blog.change_post(post)
    render(conn, "edit.html", post: post, changeset: changeset)
  end

  def update(conn, %{"id" => id, "post" => post_params}) do
    post = Blog.get_post!(conn.assigns[:user], id)

    case Blog.update_post(post, post_params) do
      {:ok, post} ->
        conn
        |> redirect(to: user_post_path(conn, :show, conn.assigns[:user], post))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", post: post, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    user = conn.assigns[:user]
    post = Blog.get_post!(user, id)
    {:ok, _post} = Blog.delete_post(post)

    conn
    |> redirect(to: user_path(conn, :show, user))
  end

  defp assign_user(conn, _opts) do
    case conn.params do
      %{"user_id" => user_id} ->
        case Micro.Repo.get(Micro.Accounts.User, user_id) do
          nil -> invalid_user(conn) # this should never happen
          user -> assign(conn, :user, user)
        end
      _ -> invalid_user(conn)
    end
  end

  defp invalid_user(conn) do
    conn
    |> put_flash(:error, "Invalid user")
    |> redirect(to: page_path(conn, :index))
  end

  defp authorize_user(conn, _opts) do
    user = conn.assigns[:user]
    current_user = conn.assigns[:current_user]
    if current_user && current_user.id == user.id do
      conn
    else
      conn
      |> put_flash(:error, "Unauthorized access of posts")
      |> redirect(to: page_path(conn, :index))
    end
  end
end
