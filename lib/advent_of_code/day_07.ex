defmodule AdventOfCode.Day07 do
  def part1(args) do
    args
    |> parse()
    |> Enum.map(&score_hand/1)
    |> Enum.sort(&sort_hands/2)
    |> Enum.with_index()
    |> Enum.map(&calculate_hand_winning/1)
    |> Enum.sum()
  end

  def part2(_args) do
  end

  def parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_hand/1)
  end

  def parse_hand(hand) do
    [cards, bet] =
      hand
      |> String.split(" ", trim: true)

    %{cards: String.to_charlist(cards) |> Enum.map(&card_value/1), bet: String.to_integer(bet)}
  end

  def card_value(?A), do: 14
  def card_value(?K), do: 13
  def card_value(?Q), do: 12
  def card_value(?J), do: 11
  def card_value(?T), do: 10
  def card_value(c) when c in ?0..?9, do: c - ?0

  @type_order ~w(five_of_a_kind four_of_a_kind full_house three_of_a_kind two_pairs one_pair high_card)a

  # Reversing it since weakest is 'rank one'
  @type_order_indexed @type_order |> Enum.reverse() |> Enum.with_index()

  def score_hand(hand) do
    type = determine_type(hand)
    type_score = score_type(type)

    Map.put_new(hand, :type, {type, type_score})
  end

  def determine_type(%{cards: cards}) do
    uniques = cards |> Enum.uniq()

    case Enum.count(uniques) do
      1 ->
        :five_of_a_kind

      4 ->
        :one_pair

      5 ->
        :high_card

      2 ->
        c = List.first(uniques)

        Enum.count(cards, &(&1 == c))
        |> case do
          1 -> :four_of_a_kind
          4 -> :four_of_a_kind
          _ -> :full_house
        end

      3 ->
        determine_3_uniques_type(uniques, cards)
    end
  end

  def determine_3_uniques_type([c | rest], cards) do
    Enum.count(cards, &(&1 == c))
    |> case do
      2 -> :two_pairs
      3 -> :three_of_a_kind
      1 -> determine_3_uniques_type(rest, cards)
    end
  end

  def score_type(to_score) do
    @type_order_indexed |> Enum.find(fn {type, _idx} -> type == to_score end) |> elem(1)
  end

  def sort_hands(%{type: {_, type1}, cards: cards1}, %{type: {_, type2}, cards: cards2}) do
    # Return true if 1 arg precedes or in same place!

    case type1 - type2 do
      0 -> sort_by_cards(cards1, cards2)
      x when x > 0 -> false
      _ -> true
    end
  end

  # Completely equal
  def sort_by_cards([], []), do: true

  def sort_by_cards([a | rest1], [b | rest2]) do
    cond do
      a == b -> sort_by_cards(rest1, rest2)
      a > b -> false
      a < b -> true
    end
  end

  def calculate_hand_winning({%{bet: bet}, idx}), do: bet * (1 + idx)
end
