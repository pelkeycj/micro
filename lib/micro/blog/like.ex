defmodule Micro.Blog.Like do
  use Ecto.Schema
  import Ecto.Changeset
  alias Micro.Blog.Like


  schema "likes" do
      belongs_to :user, Micro.Accounts.User
      belongs_to :post, Micro.Blog.Post
    timestamps()
  end

  @doc false
  def changeset(%Like{} = like, attrs) do
    like
    |> cast(attrs, [:user_id, :post_id])
    |> validate_required([:user_id, :post_id])
    #|> unique_constraint(:user_id, :post_id)

  end
end
