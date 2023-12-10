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
               %{cards_for_type: [1, 1, 2, 3, 4]},
               %{cards_for_type: [1, 1, 2, 2, 4]},
               %{cards_for_type: [1, 1, 1, 3, 4]},
               %{cards_for_type: [1, 1, 2, 1, 2]},
               %{cards_for_type: [5, 1, 2, 3, 4]},
               %{cards_for_type: [1, 1, 1, 1, 4]},
               %{cards_for_type: [1, 1, 1, 1, 1]}
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
    hand1 =
      %{cards: [10, 10, 11, 11, 10], cards_for_type: [10, 10, 11, 11, 10], bet: 220}
      |> score_hand()

    # one pair
    hand2 =
      %{cards: [13, 1, 11, 11, 10], cards_for_type: [13, 1, 11, 11, 10], bet: 220} |> score_hand()

    assert [^hand2, ^hand1] = [hand1, hand2] |> Enum.sort(&sort_hands/2)
    assert [^hand2, ^hand1] = [hand2, hand1] |> Enum.sort(&sort_hands/2)
  end

  test "orders same types" do
    # Full house
    hand1 =
      %{cards_for_type: [10, 1, 11, 11, 10], cards: [10, 1, 11, 11, 10], bet: 220} |> score_hand()

    # one pair
    hand2 =
      %{cards: [10, 11, 13, 11, 10], cards_for_type: [10, 11, 13, 11, 10], bet: 220}
      |> score_hand()

    assert [^hand1, ^hand2] = [hand1, hand2] |> Enum.sort(&sort_hands/2)
    assert [^hand1, ^hand2] = [hand2, hand1] |> Enum.sort(&sort_hands/2)
  end

  test "part1" do
    input = @input
    result = part1(input)

    assert result == 6440
  end

  test "part2" do
    input = @input
    result = part2(input)

    assert result == 5905
  end

  describe "replace jokers" do
    @j 11
    test "all jokers go to A" do
      cards = [@j, @j, @j, @j, @j]
      assert [14, 14, 14, 14, 14] = replace_jokers(cards, cards |> count_jokers())
    end

    test "4 jokers makes 5 of a kind" do
      cards = [@j, @j, 3, @j, @j]
      assert [3, 3, 3, 3, 3] = replace_jokers(cards, cards |> count_jokers())
    end

    test "3 jokers and pair makes 5 of a kind" do
      cards = [@j, 3, 3, @j, @j]
      assert [3, 3, 3, 3, 3] = replace_jokers(cards, cards |> count_jokers())
    end

    test "3 jokers and 2 random makes 4 of a kind" do
      cards = [@j, 3, 2, @j, @j]
      assert [3, 3, 2, 3, 3] = replace_jokers(cards, cards |> count_jokers())
    end

    test "2 jokers and three of a kind makes 5 of a kind" do
      cards = [@j, 2, 2, @j, 2]
      assert [2, 2, 2, 2, 2] = replace_jokers(cards, cards |> count_jokers())
    end

    test "2 jokers and a 2 of a kind makes 4 of a kind" do
      cards = [@j, 8, 2, @j, 2]
      assert [2, 8, 2, 2, 2] = replace_jokers(cards, cards |> count_jokers())
    end

    test "2 jokers and 3 random cards 3 of a kind" do
      cards = [@j, 1, 2, @j, 9]
      assert [9, 1, 2, 9, 9] = replace_jokers(cards, cards |> count_jokers())
    end

    test "1 jokers and 4 random cards 2 of a kind" do
      cards = [@j, 1, 2, 13, 9]
      assert [13, 1, 2, 13, 9] = replace_jokers(cards, cards |> count_jokers())
    end

    test "1 jokers and 1 pair makes 3 of a kind" do
      cards = [1, 13, @j, 13, 9]
      assert [1, 13, 13, 13, 9] = replace_jokers(cards, cards |> count_jokers())
    end

    test "1 jokers and 2 pairs makes full house" do
      cards = [2, 1, 2, 1, @j]
      assert [2, 1, 2, 1, 2] = replace_jokers(cards, cards |> count_jokers())
    end

    test "1 jokers and 2 pairs makes full house with highest number" do
      cards = [2, 10, 2, 10, @j]
      assert [2, 10, 2, 10, 10] = replace_jokers(cards, cards |> count_jokers())
    end

    test "1 joker with 3 of a kind makes 4 of a kind" do
      cards = [3, @j, 9, 9, 9]
      assert [3, 9, 9, 9, 9] = replace_jokers(cards, cards |> count_jokers())
    end

    test "1 joker with 4 of a kind makes 5 of a kind" do
      cards = [9, @j, 9, 9, 9]
      assert [9, 9, 9, 9, 9] = replace_jokers(cards, cards |> count_jokers())
    end

    test "0 jokers does not replace anything" do
      cards = [9, 3, 2, 1, 5]
      assert [9, 3, 2, 1, 5] = replace_jokers(cards, cards |> count_jokers())
    end

    def count_jokers(cards), do: Enum.count(cards, &(&1 == @j))
  end
end
