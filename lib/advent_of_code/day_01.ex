defmodule AdventOfCode.Day01 do
  def part1(args) do
    solve(args)
  end

  def part2(args) do
    solve(args)
  end

  def solve(input) do
    input
    |> clean_input()
    |> Enum.map(&calculate_line/1)
    |> Enum.sum()
  end

  def calculate_line(line) do
    numbers =
      line
      |> parse()

    List.first(numbers) * 10 + List.last(numbers)
  end

  @numbers ~w[one two three four five six seven eight nine]

  def parse(""), do: []
  def parse(<<i>> <> rest) when i in ?1..?9, do: [i - ?0 | parse(rest)]

  for {word, i} <- Enum.zip(@numbers, 1..9) do
    def parse(unquote(word) <> _ = line) do
      <<_>> <> rest = line
      [unquote(i) | parse(rest)]
    end
  end

  def parse(<<_>> <> rest), do: parse(rest)

  defp clean_input(input) do
    input
    |> String.trim()
    |> String.split("\n")
  end
end
