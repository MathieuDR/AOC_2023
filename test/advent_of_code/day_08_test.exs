defmodule AdventOfCode.Day08Test do
  use ExUnit.Case

  import AdventOfCode.Day08

  @input1 """
  RL

  AAA = (BBB, CCC)
  BBB = (DDD, EEE)
  CCC = (ZZZ, GGG)
  DDD = (DDD, DDD)
  EEE = (EEE, EEE)
  GGG = (GGG, GGG)
  ZZZ = (ZZZ, ZZZ)
  """

  @input2 """
  LLR

  AAA = (BBB, BBB)
  BBB = (AAA, ZZZ)
  ZZZ = (ZZZ, ZZZ)
  """

  test "parse instr" do
    assert [:left, :left, :right, :left, :left, :right] = "LLRLLR" |> parse_instructions()
  end

  test "parse map" do
    assert {"DDD", {"ABB", "ADD"}} = "DDD = (ABB, ADD)" |> parse_map()
  end

  test "part1" do
    input = @input1
    result = part1(input)

    assert result == 2
  end

  test "part1 b" do
    input = @input2
    result = part1(input)

    assert result == 6
  end

  test "part2" do
    input = """
    LR

    11A = (11B, XXX)
    11B = (XXX, 11Z)
    11Z = (11B, XXX)
    22A = (22B, XXX)
    22B = (22C, 22C)
    22C = (22Z, 22Z)
    22Z = (22B, 22B)
    XXX = (XXX, XXX)
    """

    result = part2(input)

    assert result == 6
  end
end
