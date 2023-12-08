defmodule AdventOfCode.Day06 do
  def part1(input) do
    input
    |> parse_input()
    |> Enum.map(&calculate_race(&1, 1))
    |> Enum.product()
  end

  def part2(_args) do
  end

  def parse_input(input) do
    String.split(input, "\n", trim: true)
    |> Enum.map(
      &(&1
        |> String.split(":", trim: true)
        |> List.last()
        |> String.split(" ", trim: true)
        |> Enum.map(fn x -> String.to_integer(x) end))
    )
    |> Enum.zip()
    |> Enum.map(fn {time, record} -> %{time: time, record: record} end)
  end

  def calculate_race(%{time: time, record: record}, increase \\ 1) do
    0..time
    |> Enum.map(fn time_pressed ->
      if time_pressed * increase * (time - time_pressed) > record do
        true
      else
        false
      end
    end)
    |> Enum.count(&(&1 == true))

    # |> Kernel.*(2)
  end
end
