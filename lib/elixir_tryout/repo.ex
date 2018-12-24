defmodule ElixirTryout.Repo do
  use Ecto.Repo,
    otp_app: :elixir_tryout,
    adapter: Ecto.Adapters.MySQL
end
