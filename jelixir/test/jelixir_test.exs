defmodule JelixirTest do
  use ExUnit.Case
  doctest Jelixir

  test "greets the world" do
    assert Jelixir.hello() == :world
  end
end
