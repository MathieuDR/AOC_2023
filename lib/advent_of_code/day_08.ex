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

    starts = Enum.filter(maps, fn {key, _} -> String.ends_with?(key, "A") end)

    paths =
      starts
      |> Enum.map(fn {key, _} ->
        traverse_until(instructions, maps, key, &String.ends_with?(&1, "Z"))
        |> Enum.to_list()
      end)
      |> Enum.map(&{Enum.count(&1), &1})

    paths
    |> Enum.map(&elem(&1, 0))
    |> IO.inspect(label: "counts till path. Find LCM")
    |> find_lcm()
  end

  def find_lcm([a]), do: a

  def find_lcm([a, b | rest]) do
    gcf = find_gcf([a, b])
    lcm = trunc(a * b / gcf)
    find_lcm([lcm | rest])
  end

  def find_gcf(numbers) do
    Enum.map(numbers, &(find_factors(&1) |> MapSet.new()))
    |> Enum.reduce(fn set, acc ->
      if is_nil(acc) do
        set
      else
        MapSet.intersection(acc, set)
      end
    end)
    |> Enum.sort(:desc)
    |> List.first()
  end

  def find_factors(number) do
    sqrt = :math.sqrt(number) |> trunc()

    1..sqrt
    |> Enum.flat_map(fn d ->
      if rem(number, d) == 0 do
        [d, trunc(number / d)]
      else
        []
      end
    end)
  end

  def traverse_until(instructions, map, current_position, end_fun) do
    Stream.cycle(instructions)
    |> Stream.transform(current_position, fn instruction, position ->
      if end_fun.(position) do
        {:halt, position}
      else
        next_position = traverse(position, instruction, map)
        {[next_position], next_position}
      end
    end)
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
