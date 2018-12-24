defmodule ElixirTryoutWeb.RootController do
    use ElixirTryoutWeb, :controller

    def index(conn, _params) do
      json(conn, %{test: "value"})
    end
  end