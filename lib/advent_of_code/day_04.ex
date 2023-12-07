defmodule AdventOfCode.Day04 do
  def part1(args) do
    args
    |> input_to_cards()
    |> Enum.map(fn %{matches: count} ->
      :math.pow(2, count - 1) |> trunc()
    end)
    |> Enum.sum()
  end

  def part2(args) do
    cards =
      args
      |> input_to_cards()

    copies =
      1..Enum.count(cards)
      |> Enum.reduce(%{}, fn game, copies -> Map.put(copies, game, 1) end)

    cards
    |> Enum.reduce(copies, fn %{id: game, matches: matches}, copies ->
      current_copies = Map.fetch!(copies, game)
      calculate_copies(copies, matches, current_copies, game)
    end)
    |> Map.values()
    |> Enum.sum()
  end

  def calculate_copies(copies, 0, _, _), do: copies

  def calculate_copies(copies, matches, copies_to_give, current_game) do
    Enum.reduce((current_game + 1)..(current_game + matches), copies, fn game, copies ->
      Map.update!(copies, game, fn game_copies -> game_copies + copies_to_give end)
    end)
  end

  def input_to_cards(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_line/1)
  end

  def parse_line("Card " <> rest) do
    [id, number_string] = String.split(rest, ":")

    [winning_numbers, scratched_numbers] =
      String.split(number_string, "|")
      |> Enum.map(fn numbers ->
        String.split(numbers, " ", trim: true)
        |> Enum.map(fn num -> String.trim(num) |> String.to_integer() end)
      end)

    %{
      id: String.trim(id) |> String.to_integer(),
      winning_numbers: winning_numbers,
      scratched_numbers: scratched_numbers,
      matches: get_duplicates(winning_numbers, scratched_numbers) |> Enum.count()
    }
  end

  defp get_duplicates(set_1, set_2),
    do: MapSet.intersection(MapSet.new(set_1), MapSet.new(set_2))
end
