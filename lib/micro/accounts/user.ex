defmodule Micro.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias Micro.Accounts.User


  schema "users" do
    field :bio, :string
    field :handle, :string
    field :name, :string
    has_many :posts, Micro.Blog.Post
    #TODO:followers, following

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
