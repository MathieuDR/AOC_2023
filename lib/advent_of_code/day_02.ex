defmodule AdventOfCode.Day02 do
  def part1(args) do
    args
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_input/1)
    |> Enum.filter(fn {_id, rounds} ->
      Enum.count(rounds, fn hand ->
        Map.get(hand, :green, 0) > 13 ||
          Map.get(hand, :red, 0) > 12 ||
          Map.get(hand, :blue, 0) > 14
      end) == 0
    end)
    |> Enum.reduce(0, fn {id, _}, acc -> acc + id end)
  end

  def part2(args) do
    args
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_input/1)
    |> Enum.map(fn {_id, rounds} ->
      Enum.reduce(rounds, %{}, fn map, acc ->
        Map.merge(map, acc, fn _, v1, v2 -> max(v1, v2) end)
      end)
    end)
    |> Enum.reduce(0, fn map, acc ->
      Map.get(map, :green, 0) * Map.get(map, :red, 0) * Map.get(map, :blue, 0) + acc
    end)
  end

  def parse_input("Game " <> rest) do
    [id, rounds] = String.split(rest, ": ")

    id = String.to_integer(id)

    rounds =
      String.split(rounds, "; ", trim: true)
      |> Enum.map(fn round ->
        String.split(round, ", ")
        |> Enum.map(fn colour_info -> String.split(colour_info, " ") end)
        |> Enum.reduce(%{}, fn [amount, colour], map ->
          Map.put(map, String.to_atom(colour), String.to_integer(amount))
        end)
      end)

    {id, rounds}
  end
end
