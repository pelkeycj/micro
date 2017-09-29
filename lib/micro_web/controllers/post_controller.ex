defmodule MicroWeb.PostController do
  use MicroWeb, :controller

  alias Micro.Blog
  alias Micro.Blog.Post

  def index(conn, _params) do
    posts = Blog.list_posts(conn.assigns[:user])
    render(conn, "index.html", posts: posts)
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
        conn
        |> put_flash(:info, "Post created successfully.")
        |> redirect(to: user_post_path(conn, :show, conn.assigns[:user], post))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
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
        |> put_flash(:info, "Post updated successfully.")
        |> redirect(to: user_post_path(conn, :show, conn.assigns[:user], post))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", post: post, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    post = Blog.get_post!(conn.assigns[:user], id)
    {:ok, _post} = Blog.delete_post(post)

    conn
    |> put_flash(:info, "Post deleted successfully.")
    |> redirect(to: user_post_path(conn, :index, conn.assigns[:user]))
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
    user = get_session(conn, :current_user)
    if user && Integer.to_string(user.id) == conn.params["user_id"] do

    end
  end
end
