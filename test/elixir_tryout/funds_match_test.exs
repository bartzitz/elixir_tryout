defmodule ElixirTryout.FundsMatchTest do
  alias ElixirTryout.FundsMatch

  use ExUnit.Case

  test "initial state is set to 'new'" do
    assert FundsMatch.new.state == :new
  end

  test "performs transition from 'new' to 'matched'" do
    funds_match = FundsMatch.new |> FundsMatch.accept_match

    assert funds_match.state == :matched
  end

  test "performs transition from 'new' to 'rejected'" do
    funds_match = FundsMatch.new |> FundsMatch.reject_match

    assert funds_match.state == :rejected
  end

  test "performs transition from 'matched' to 'new'" do
    funds_match = FundsMatch.new |> FundsMatch.accept_match |> FundsMatch.reset_match

    assert funds_match.state == :new
  end

  test "performs transition from 'rejected' to 'new'" do
    funds_match = FundsMatch.new |> FundsMatch.reject_match |> FundsMatch.reset_match

    assert funds_match.state == :new
  end
end
