defmodule AdventOfCode.Day07Test do
  use ExUnit.Case

  import AdventOfCode.Day07

  @input """
  32T3K 765
  T55J5 684
  KK677 28
  KTJJT 220
  QQQJA 483
  """

  test "parsing" do
    assert [
             %{cards: [3, 2, 10, 3, 13], bet: 765},
             %{cards: [10, 5, 5, 11, 5], bet: 684},
             %{cards: [13, 13, 6, 7, 7], bet: 28},
             %{cards: [13, 10, 11, 11, 10], bet: 220},
             %{cards: [12, 12, 12, 11, 14], bet: 483}
           ] = parse(@input)
  end

  test "determing type" do
    assert [
             :one_pair,
             :two_pairs,
             :three_of_a_kind,
             :full_house,
             :high_card,
             :four_of_a_kind,
             :five_of_a_kind
           ] =
             [
               %{cards: [1, 1, 2, 3, 4]},
               %{cards: [1, 1, 2, 2, 4]},
               %{cards: [1, 1, 1, 3, 4]},
               %{cards: [1, 1, 2, 1, 2]},
               %{cards: [5, 1, 2, 3, 4]},
               %{cards: [1, 1, 1, 1, 4]},
               %{cards: [1, 1, 1, 1, 1]}
             ]
             |> Enum.map(&determine_type/1)
  end

  test "score types" do
    assert [1, 2, 3, 4, 0, 5, 6] =
             [
               :one_pair,
               :two_pairs,
               :three_of_a_kind,
               :full_house,
               :high_card,
               :four_of_a_kind,
               :five_of_a_kind
             ]
             |> Enum.map(&score_type/1)
  end

  test "orders different types" do
    # Full house
    hand1 = %{cards: [10, 10, 11, 11, 10], bet: 220} |> score_hand()

    # one pair
    hand2 = %{cards: [13, 1, 11, 11, 10], bet: 220} |> score_hand()

    assert [^hand2, ^hand1] = [hand1, hand2] |> Enum.sort(&sort_hands/2)
    assert [^hand2, ^hand1] = [hand2, hand1] |> Enum.sort(&sort_hands/2)
  end

  test "orders same types" do
    # Full house
    hand1 = %{cards: [10, 1, 11, 11, 10], bet: 220} |> score_hand()

    # one pair
    hand2 = %{cards: [10, 11, 13, 11, 10], bet: 220} |> score_hand()

    assert [^hand1, ^hand2] = [hand1, hand2] |> Enum.sort(&sort_hands/2)
    assert [^hand1, ^hand2] = [hand2, hand1] |> Enum.sort(&sort_hands/2)
  end

  test "part1" do
    input = @input
    result = part1(input)

    assert result == 6440
  end

  @tag :skip
  test "part2" do
    input = @input
    result = part2(input)

    assert result
  end
end
