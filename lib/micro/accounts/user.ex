defmodule Micro.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias Micro.Accounts.{User, Relationship}


  schema "users" do
    field :bio, :string
    field :handle, :string
    field :name, :string
    has_many :posts, Micro.Blog.Post
    has_many :likes, Micro.Blog.Like
    many_to_many :relationships, Relationship, join_through: "relationships",
           join_keys: [follower_id: :id, following_id: :id]
    # user authentication
    # use a hashed password and rate limit failed login
    # attempts
    field :password_hash, :string
    field :pw_tries, :integer
    field :pw_last_try, :utc_datetime

    # used for registration
    field :password, :string, virtual: true
    field :password_confirmation, :string, virtual: true

    timestamps()
  end


  @doc false
  def changeset(%User{} = user, attrs) do
    user
    |> cast(attrs, [:name, :handle, :bio, :password, :password_confirmation])
    |> validate_confirmation(:password)
    |> validate_password(:password)
    |> put_pass_hash()
    |> validate_required([:name, :handle, :password_hash])
    |> unique_constraint(:handle)
  end

  # Password validation
  # From Comeonin documentation
  def validate_password(changeset, field, options \\ []) do
    validate_change(changeset, field, fn _, password ->
      case valid_password?(password) do
        {:ok, _} -> []
        {:error, msg} -> [{field, options[:message] || msg}]
      end
    end)
  end

  def put_pass_hash(%Ecto.Changeset{valid?: true, changes: %{password: password}} = changeset) do
    change(changeset, Comeonin.Argon2.add_hash(password))
  end

  def put_pass_hash(changeset), do: changeset

  def valid_password?(password) when byte_size(password) > 7 do
    {:ok, password}
  end

  def valid_password?(_), do: {:error, "The password is too short"}


  # written by Nat Tuck
  def update_tries(throttle, prev) do
    if throttle do
      prev + 1
    else
      1
    end
  end

  # written by Nat Tuck
  def throttle_attempts(user) do
    y2k = DateTime.from_naive!(~N[2000-01-01 00:00:00], "Etc/UTC")
    previous = DateTime.to_unix(user.pw_last_try || y2k)
    now = DateTime.to_unix(DateTime.utc_now())
    throttle = (now - previous) < 3600

    if (throttle && user.pw_tries > 5) do
      nil
    else
      changes = %{
        pw_tries: update_tries(throttle, user.pw_tries),
        pw_last_try: DateTime.utc_now()
      }
      {:ok, user} = Ecto.Changeset.cast(user, changes, [:pw_tries, :pw_last_try])
      |> Micro.Repo.update
    end
  end

end
