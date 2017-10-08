defmodule Micro.Blog do
  @moduledoc """
  The Blog context.
  """

  import Ecto.Query, warn: false
  alias Micro.Repo

  alias Micro.Blog.Post

  @doc """
  Returns the list of posts.

  ## Examples

      iex> list_posts()
      [%Post{}, ...]

  """
  def list_posts(user) do
      Repo.all(Ecto.assoc(user, :posts))
      |> Repo.preload(:user)
  end

  @doc """
  Gets a single post.

  Raises `Ecto.NoResultsError` if the Post does not exist.

  ## Examples

      iex> get_post!(123)
      %Post{}

      iex> get_post!(456)
      ** (Ecto.NoResultsError)

  """
  def get_post!(user, id) do
    Repo.get!(Ecto.assoc(user, :posts), id)
    |> Repo.preload(:user)

  end

  @doc """
  Creates a post.

  ## Examples

      iex> create_post(%{field: value})
      {:ok, %Post{}}

      iex> create_post(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_post(user, attrs \\ %{}) do
   # changeset =
    user
    |> Ecto.build_assoc(:posts)
    |> Post.changeset(attrs)
    |> Repo.insert()

   # %Post{}
   # |> Post.changeset(attrs)
   # |> Repo.insert()
  end

  @doc """
  Updates a post.

  ## Examples

      iex> update_post(post, %{field: new_value})
      {:ok, %Post{}}

      iex> update_post(post, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_post(%Post{} = post, attrs) do
    post
    |> Post.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Post.

  ## Examples

      iex> delete_post(post)
      {:ok, %Post{}}

      iex> delete_post(post)
      {:error, %Ecto.Changeset{}}

  """
  def delete_post(%Post{} = post) do
    Repo.delete(post)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking post changes.

  ## Examples

      iex> change_post(post)
      %Ecto.Changeset{source: %Post{}}

  """
  def change_post(%Post{} = post) do
    Post.changeset(post, %{})
  end

  @doc """
    Gets a list of posts by all the given users
  """
  def get_posts_for_users(users) do
    users
    |> Enum.flat_map(fn x -> list_posts(x)  end)
  end

  @doc """
    sorts
  """
  def sort_posts_by_time(posts) do
    Enum.sort(posts, &((&1).inserted_at >= (&2).inserted_at))  end

  alias Micro.Blog.Like


  def list_post_likes(post_id) do
    Repo.all(from l in Like,
              where: l.post_id == ^post_id)
            |> Repo.preload(:user)
  end

  @doc """
  Returns the list of likes.

  ## Examples

      iex> list_likes()
      [%Like{}, ...]

  """
  def list_likes do
    Repo.all(Like)
    |> Repo.preload(:user)
    |> Repo.preload(:post)
  end

  def get_like!(post_id, user_id) do
    Repo.all(from l in Like,
            where: l.post_id == ^post_id and l.user_id == ^user_id)
  end

  @doc """
  Gets a single like.

  Raises `Ecto.NoResultsError` if the Like does not exist.

  ## Examples

      iex> get_like!(123)
      %Like{}

      iex> get_like!(456)
      ** (Ecto.NoResultsError)

  """
  def get_like!(id) do
    Repo.get!(Like, id)
    |> Repo.preload(:user)
    |> Repo.preload(:post)
  end
  @doc """
  Creates a like.

  ## Examples

      iex> create_like(%{field: value})
      {:ok, %Like{}}

      iex> create_like(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_like(attrs \\ %{}) do
    %Like{}
    |> Like.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a like.

  ## Examples

      iex> update_like(like, %{field: new_value})
      {:ok, %Like{}}

      iex> update_like(like, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_like(%Like{} = like, attrs) do
    like
    |> Like.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Like.

  ## Examples

      iex> delete_like(like)
      {:ok, %Like{}}

      iex> delete_like(like)
      {:error, %Ecto.Changeset{}}

  """
  def delete_like(%Like{} = like) do
    Repo.delete(like)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking like changes.

  ## Examples

      iex> change_like(like)
      %Ecto.Changeset{source: %Like{}}

  """
  def change_like(%Like{} = like) do
    Like.changeset(like, %{})
  end
end
