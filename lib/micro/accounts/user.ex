defmodule Micro.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias Micro.Accounts.{User, Relationship}


  schema "users" do
    field :bio, :string
    field :handle, :string
    field :name, :string
    has_many :posts, Micro.Blog.Post
    #has_many :followings, through: [:relationships, :followings]
    many_to_many :relationships, Relationship, join_through: "relationships",
           join_keys: [follower_id: :id, following_id: :id]

    timestamps()
  end

  @doc false
  def changeset(%User{} = user, attrs) do
    user
    |> cast(attrs, [:name, :handle, :bio])
    |> validate_required([:name, :handle])
    |> unique_constraint(:handle)
  end
end
