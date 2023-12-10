defmodule AdventOfCode.Day07 do
  def part1(args) do
    args
    |> parse()
    |> Enum.map(fn %{cards: cards} = hand ->
      Map.put_new(hand, :cards_for_type, cards)
      |> score_hand()
    end)
    |> Enum.sort(&sort_hands/2)
    |> Enum.with_index()
    |> Enum.map(&calculate_hand_winning/1)
    |> Enum.sum()
  end

  def part2(args) do
    args
    |> parse()
    |> Enum.map(fn %{cards: cards} = hand ->
      replaced_cards = replace_jokers(cards, Enum.count(cards, &(&1 == 11)))

      cards = replace_jokers_with(cards, 1)

      Map.put_new(hand, :cards_for_type, replaced_cards)
      |> Map.replace!(:cards, cards)
      |> score_hand()
    end)
    |> Enum.sort(&sort_hands/2)
    |> Enum.with_index()
    |> Enum.map(&calculate_hand_winning/1)
    |> Enum.sum()
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

  def determine_type(cards) when is_list(cards), do: determine_type(%{cards_for_type: cards})

  def determine_type(%{cards_for_type: cards}) do
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

  def replace_jokers(_cards, 5), do: [14, 14, 14, 14, 14]

  def replace_jokers(cards, 4) do
    [card] = cards |> Enum.reject(&(&1 == 11))
    [card, card, card, card, card]
  end

  def replace_jokers(cards, 3), do: replace_jokers_with_highest(cards)

  def replace_jokers(cards, 2) do
    uniques =
      cards
      |> Enum.reject(&(&1 == 11))
      |> Enum.uniq()

    case uniques |> Enum.count() do
      3 ->
        replace_jokers_with_highest(cards)

      _ ->
        first = List.first(uniques)

        case Enum.count(cards, &(&1 == first)) do
          1 -> replace_jokers_with(cards, List.last(uniques))
          _ -> replace_jokers_with(cards, first)
        end
    end
  end

  def replace_jokers(cards, 1) do
    uniques =
      cards
      |> Enum.reject(&(&1 == 11))
      |> Enum.uniq()

    case uniques |> Enum.count() do
      4 ->
        replace_jokers_with_highest(cards)

      3 ->
        replace_jokers_with(cards, find_pair(uniques, cards))

      2 ->
        f = List.first(uniques)

        case Enum.count(cards, &(&1 == f)) do
          1 -> replace_jokers_with(cards, List.last(uniques))
          3 -> replace_jokers_with(cards, f)
          2 -> replace_jokers_with(cards, Enum.max(uniques))
        end

      1 ->
        replace_jokers_with(cards, List.first(uniques))
    end
  end

  def replace_jokers(cards, 0), do: cards

  def find_pair([c | rest], cards) do
    case Enum.count(cards, &(&1 == c)) do
      1 -> find_pair(rest, cards)
      _ -> c
    end
  end

  def replace_jokers_with_highest(cards) do
    high = Enum.reject(cards, &(&1 == 11)) |> Enum.max()
    cards |> replace_jokers_with(high)
  end

  def replace_jokers_with(cards, card),
    do:
      Enum.map(
        cards,
        &case &1 do
          11 -> card
          _ -> &1
        end
      )
end
