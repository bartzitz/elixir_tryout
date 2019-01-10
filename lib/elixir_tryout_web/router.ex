defmodule ElixirTryoutWeb.Router do
  use ElixirTryoutWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
    plug ElixirTryoutWeb.PrincipalIdentifierChecker
  end

  # pipeline :principle_identifier_check do
  #   plug ElixirTryoutWeb.PrincipalIdentifierChecker
  # end

  scope "/api", ElixirTryoutWeb do
    pipe_through :api
    # pipe_through [:api, :principle_identifier_check]

    get "/", RootController, :index

    get "/transactions", TransactionsController, :index
    get "/transactions/:id", TransactionsController, :show
    post "/transactions", TransactionsController, :create
    put "/transactions/:id", TransactionsController, :update
  end
end
