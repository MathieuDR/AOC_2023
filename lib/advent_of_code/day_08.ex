defmodule AdventOfCode.Day08 do
  def part1(input) do
    input
    |> parse()
    |> then(fn info ->
      traverse_to(info, "ZZZ", "AAA", info[:instructions], [])
    end)
    |> Enum.count()
  end

  def part2(input) do
    %{instructions: instructions, map: maps} = parse(input)

    starts =
      Enum.filter(maps, fn {key, _} -> String.ends_with?(key, "A") end)
      |> Enum.map(&elem(&1, 0))
      |> IO.inspect()

    Stream.cycle(instructions)
    |> Stream.transform({0, starts}, fn instruction, {steps, acc} ->
      acc
      |> case do
        -1 ->
          {:halt, acc}

        _ ->
          acc = Enum.map(acc, fn position -> traverse(position, instruction, maps) end)
          steps = steps + 1

          if rem(steps, 5_000_000) == 0 do
            IO.inspect(steps / 1_000_000, label: "steps (M)")
          end

          case reached_end?(acc) do
            true ->
              {[steps], {steps, -1}}

            false ->
              {[], {steps, acc}}
          end
      end
    end)
    |> Enum.to_list()
    |> List.first()
  end

  def reached_end?(positions) do
    Enum.count(positions, &String.ends_with?(&1, "Z")) == Enum.count(positions)
  end

  def traverse(position, instruction, map) do
    {left, right} = map[position]

    case instruction do
      :left -> left
      :right -> right
    end
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
    next_destination = traverse(current_position, instruction, info[:map])

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
end
