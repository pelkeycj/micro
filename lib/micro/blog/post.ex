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
    #|> strip_unsafe_md(attrs)
  end

  @docp """
  def strip_unsafe_md(post, %{"body" => body}) do
    {:safe, safe_body} = Phoenix.HTML.html_escape(body)
    post
    |> put_change(:body, safe_body)
  end

    """

  def as_markdown(txt) do
    txt
    |> Earmark.as_html!()
    |> Phoenix.HTML.raw()
  end
end
