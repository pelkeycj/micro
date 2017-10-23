defmodule Micro.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias Micro.Repo

  alias Micro.Accounts.{User, Relationship}

  @doc """
  Returns the list of users.

  ## Examples

      iex> list_users()
      [%User{}, ...]

  """
  def list_users do
    Repo.all(User)
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id), do: Repo.get!(User, id)

  @doc """
  Creates a user.

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a user.

  ## Examples

      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a User.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{source: %User{}}

  """
  def change_user(%User{} = user) do
    User.changeset(user, %{})
  end

  @doc """
  Gets a User.


  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user_by_handle!(123)
      %User{}

      iex> get_user_by_handle!(456)
      ** (Ecto.NoResultsError)
  """
  def get_user_by_handle!(handle) do
    Repo.get_by(User, handle: handle)
  end

  @doc """
    Creates a follow relationship between two Users.

    ## Examples

      iex> create_relationship(%{field: value})
          %Relationship{}
  """
  def create_relationship(attrs) do
    %Relationship{}
    |> Relationship.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
    Deletes a Relationship.

      ## Examples

      iex> delete_relationship(relationship)
      {:ok, %Relationship{}}

      iex> delete_relationship(relationship)
      {:error, %Ecto.Changeset{}}
  """
  def delete_relationship(relationship) do
    Repo.delete(relationship)
  end


  @doc """
    Gets a Relationship.
  """
  def get_relationship(follower_id, following_id) do
    Repo.one(from r in Relationship,
        where: r.follower_id == ^follower_id and r.following_id == ^following_id,
        select: r)
  end

  @doc """
    Gets the followers of the given user as a list of Users.
  """
  def get_followers(user_id) do
    Repo.all(from r in Relationship,
             order_by: r.inserted_at,
             where: r.following_id == ^user_id,
             select: r.follower_id)
    |> Enum.map(fn x ->
        get_user!(x) end)
  end

  @doc """
    Gets the followings of the given user as a list of Users.
  """
  def get_followings(user_id) do
    Repo.all(from r in Relationship,
             order_by: r.inserted_at,
             where: r.follower_id == ^user_id,
             select: r.following_id)
    |> Enum.map( fn x -> get_user!(x) end)
  end

  @doc """
    Counts the number of followers a User has.
  """
  def follower_count(user_id) do
    get_followers(user_id)
    |> Enum.count()
  end

  @doc """
    Counts the number of followings a User has.
  """
  def following_count(user_id) do
    get_followings(user_id)
    |> Enum.count()
  end

  @doc """
    Gets a list of Users that are not followed by the given User.
  """
  def get_strangers(user_id) do
    followings = get_followings(user_id) ++ [get_user!(user_id)]
    list_users()
    |> Enum.filter(fn x -> !Enum.member?(followings, x) end)
  end

  @doc """
    Broadcasts the Post to the updates:follower_id channel for
    all followers of user_id.
  """
  def broadcast_post_to_followers(user_id, post) do
    post = Repo.preload(post, :user)
    Repo.all(from r in Relationship,
              where: r.following_id == ^user_id,
              select: r.follower_id) ++ [user_id]
    |> Enum.map(fn x ->
          MicroWeb.Endpoint.broadcast("updates:#{x}", "following_post", %{post_id: post.id, post_title: post.title,
            post_body: post.body, user_id: post.user.id, user_handle: post.user.handle, user_name: post.user.name})
    end)
   ##  body: post.body, user_id: post.user.id, user_handle: post.user.handle}) # see own post
  end

  @doc """
    Gets a User with the given handle and authorizes them
    with the given password.
  """
  def get_and_auth_user(handle, password) do
    user = get_user_by_handle!(handle)

    if user do
      User.throttle_attempts(user)
    end
    case Comeonin.Argon2.check_pass(user, password) do
      {:ok, user} -> user
      _else       -> nil
    end
  end


end
