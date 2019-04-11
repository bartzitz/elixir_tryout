defmodule ElixirTryoutWeb.Router do
  use ElixirTryoutWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", ElixirTryoutWeb do
    pipe_through :browser

    get "/", RootController, :index_html
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
