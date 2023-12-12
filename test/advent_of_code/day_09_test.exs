defmodule AdventOfCode.Day09Test do
  use ExUnit.Case

  import AdventOfCode.Day09

  test "part2" do
    input = """
    10  13  16  21  30  45
    """

    result = part2(input)

    assert result == 5
  end
end
