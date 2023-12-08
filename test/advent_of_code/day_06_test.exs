defmodule AdventOfCode.Day06Test do
  use ExUnit.Case

  import AdventOfCode.Day06

  @example """
      Time:      7  15   30
      Distance:  9  40  200
  """

  test "parse" do
    assert [%{time: 7, record: 9}, %{time: 15, record: 40}, %{time: 30, record: 200}] =
             parse_input(@example)
  end

  test "part1" do
    input = @example
    result = part1(input)

    assert result == 288
  end

  @tag :skip
  test "part2" do
    input = nil
    result = part2(input)

    assert result
  end
end
