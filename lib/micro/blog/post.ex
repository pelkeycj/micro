defmodule Micro.Blog.Post do
  use Ecto.Schema
  import Ecto.Changeset
  alias Micro.Blog.Post


  schema "posts" do
    field :body, :string
    field :title, :string
    belongs_to :user, Micro.Accounts.User
    has_many :likes, Micro.Blog.Like

    timestamps()
  end

  @doc false
  def changeset(%Post{} = post, attrs) do
    post
    |> cast(attrs, [:title, :body])
    |> validate_required([:title, :body])
  end

  def as_markdown(txt) do
    txt
    |> Earmark.as_html!()
    |> Phoenix.HTML.raw()
  end
end
