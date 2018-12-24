defmodule ElixirTryoutWeb.Router do
  use ElixirTryoutWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", ElixirTryoutWeb do
    pipe_through :api

    get "/", RootController, :index
  end
end
