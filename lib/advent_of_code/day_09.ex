defmodule AdventOfCode.Day09 do
  def part1(args) do
    parse(args)
    |> Enum.map(&predict_next_number/1)
    |> Enum.sum()
  end

  def part2(args) do
    parse(args, true)
    |> Enum.map(&predict_next_number/1)
    |> Enum.sum()
  end

  def parse(input, reverse \\ false) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      String.split(line, " ", trim: true)
      |> Enum.map(&String.to_integer/1)
      |> then(fn res ->
        case reverse do
          true -> Enum.reverse(res)
          false -> res
        end
      end)
    end)
  end

  def predict_next_number(numbers) do
    get_to_zero_diff(numbers)
    |> Enum.map(&List.last/1)
    |> Enum.sum()
  end

  def get_to_zero_diff(numbers, acc \\ []) do
    acc = [numbers | acc]

    case all_zero?(numbers) do
      true ->
        acc

      false ->
        new_nums = get_difference(numbers)
        get_to_zero_diff(new_nums, acc)
    end
  end

  def all_zero?(numbers), do: Enum.uniq(numbers) |> Enum.count() == 1 && List.first(numbers) == 0

  def get_difference(numbers) do
    Enum.drop(numbers, 1)
    |> Enum.zip(numbers)
    |> Enum.map(fn {a, b} -> a - b end)
  end
end
