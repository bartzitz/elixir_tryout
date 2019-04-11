defmodule ElixirTryoutWeb.RootController do
  use ElixirTryoutWeb, :controller

  def index(conn, _params) do
    json(conn, %{test: "value"})
  end

  def index_html(conn, _params) do
    render(conn, "index.html")
  end
end