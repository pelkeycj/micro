defmodule MicroWeb.PageController do
  use MicroWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
