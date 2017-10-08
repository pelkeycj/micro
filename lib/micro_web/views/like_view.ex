defmodule MicroWeb.LikeView do
  use MicroWeb, :view
  alias MicroWeb.LikeView

  def render("index.json", %{likes: likes}) do
    %{data: render_many(likes, LikeView, "like.json")}
  end

  def render("show.json", %{like: like}) do
    %{data: render_one(like, LikeView, "like.json")}
  end

  def render("like.json", %{like: like}) do
    %{id: like.id, user_id: like.user_id, user_handle: like.user.handle, user_name: like.user.name, post_id: like.post_id}
  end
end
