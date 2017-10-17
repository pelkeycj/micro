defmodule MicroWeb.PageController do
  use MicroWeb, :controller

  def index(conn, _params) do
    user = conn.assigns[:current_user]
    if user do
      redirect(conn, to: relationship_path(conn, :index, [view: "home", user: user]))
    end
    render conn, "index.html"
  end
end
