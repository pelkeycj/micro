defmodule Micro.Blog.Post do
  use Ecto.Schema
  import Ecto.Changeset
  alias Micro.Blog.Post


  schema "posts" do
    field :body, :string
    field :tags, :string
    field :title, :string

    timestamps()
  end

  @doc false
  def changeset(%Post{} = post, attrs) do
    post
    |> cast(attrs, [:title, :body, :tags])
    |> validate_required([:title, :body, :tags])
  end
end