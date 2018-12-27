defmodule ElixirTryoutWeb.Router do
  use ElixirTryoutWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", ElixirTryoutWeb do
    pipe_through :api

    get "/", RootController, :index

    get "/transactions", TransactionsController, :index
    get "/transactions/:id", TransactionsController, :show
    post "/transactions", TransactionsController, :create
    put "/transactions/:id", TransactionsController, :update
  end
end
