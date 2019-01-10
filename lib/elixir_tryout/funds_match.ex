defmodule ElixirTryout.FundsMatch do
  use Fsm, initial_state: :new

  defstate new do
    defevent accept_match, do: next_state(:matched)

    defevent reject_match, do: next_state(:rejected)
  end

  defstate matched do
    defevent reset_match, do: next_state(:new)
  end

  defstate rejected do
    defevent reset_match, do: next_state(:new)
  end
end
