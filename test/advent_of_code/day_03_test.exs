defmodule AdventOfCode.Day03Test do
  use ExUnit.Case

  import AdventOfCode.Day03

  test "line to map has correct output" do
    input = "467..114.."

    assert line_to_map(input) == %{
             0 => {0, 467},
             1 => {0, 467},
             2 => {0, 467},
             5 => {5, 114},
             6 => {5, 114},
             7 => {5, 114},
             symbols: [],
             gears: []
           }
  end

  test "Can read when it's at the end" do
    input = "..*123"

    assert line_to_map(input) == %{
             3 => {3, 123},
             4 => {3, 123},
             5 => {3, 123},
             symbols: [2],
             gears: [2]
           }
  end

  test "can read number when inbetween symbols" do
    input = "..*123b..."

    assert line_to_map(input) == %{
             3 => {3, 123},
             4 => {3, 123},
             5 => {3, 123},
             symbols: [6, 2],
             gears: [2]
           }
  end

  test "test random stuff" do
    input = """
    .x123
    """

    assert [123] =
             input_to_map(input)
             |> get_numbers_touching_symbols()
  end

  test "Gets adjecent number" do
    input = """
    .x023..
    11.....
    """

    assert [11, 23] =
             input_to_map(input)
             |> get_numbers_touching_symbols()
  end

  test "can create gear ratio" do
    input = "..11*123.."

    assert 1353 == input |> input_to_map() |> get_gear_ratios |> Enum.sum()
  end

  test "can convert multiline to map" do
    input = """
    ..123..
    11.....
    """

    assert input_to_map(input) == %{
             0 => %{2 => {2, 123}, 3 => {2, 123}, 4 => {2, 123}, symbols: [], gears: []},
             1 => %{0 => {0, 11}, 1 => {0, 11}, symbols: [], gears: []}
           }
  end

  test "part1" do
    input = """
    467..114..
    ...*......
    ..35..633.
    ......#...
    617*......
    .....+.58.
    ..592.....
    ......755.
    ...$.*....
    .664.598..
    """

    result = part1(input)

    assert result == 4361
  end

  @tag :skip
  test "part2" do
    input = nil
    result = part2(input)

    assert result
  end
end
