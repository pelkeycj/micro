defmodule MicroWeb.PageControllerTest do
  use MicroWeb.ConnCase

  @docp """
  test "GET /", %{conn: conn} do
    conn = get conn, "/"
    assert html_response(conn, 200) =~ "Welcome to Phoenix!"
  end
  """

end
