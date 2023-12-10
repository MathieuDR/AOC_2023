defmodule AdventOfCode.Day08 do
  def part1(input) do
    input
    |> parse()
    |> then(fn info ->
      traverse_to(info, "ZZZ", "AAA", info[:instructions], [])
    end)
    |> Enum.count()
  end

  def part2(_args) do
  end

  def traverse_to(_, destination, current_position, _, acc)
      when current_position == destination,
      do: acc

  def traverse_to(info, destination, current_position, [], acc),
    do: traverse_to(info, destination, current_position, info[:instructions], acc)

  def traverse_to(
        info,
        destination,
        current_position,
        [instruction | left_over_instructions],
        acc
      ) do
    {left, right} = info[:map][current_position]

    next_destination =
      case instruction do
        :left -> left
        :right -> right
      end

    traverse_to(info, destination, next_destination, left_over_instructions, [
      next_destination | acc
    ])
  end

  def parse(input) do
    [instructions, map] = String.split(input, "\n\n", trim: true, parts: 2)

    instructions = parse_instructions(instructions)

    map =
      map
      |> String.split("\n", trim: true)
      |> Enum.map(&parse_map/1)
      |> Enum.reduce(%{}, fn {key, value}, acc -> Map.put_new(acc, key, value) end)

    %{instructions: instructions, map: map}
  end

  def parse_instructions(str, acc \\ [])

  def parse_instructions("", acc), do: Enum.reverse(acc)

  def parse_instructions("L" <> rest, acc), do: parse_instructions(rest, [:left | acc])
  def parse_instructions("R" <> rest, acc), do: parse_instructions(rest, [:right | acc])

  def parse_map(line) do
    [key, rest] = String.split(line, " = ")
    [left, right] = String.slice(rest, 1..8) |> String.split(", ")
    {key, {left, right}}
  end

  # def get_next_instruction([], instructions), do: get_next_instruction(instructions, instructions)
  # def get_next_instruction([head | tail], _instructions), do: {head, tail}
end
