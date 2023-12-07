defmodule AdventOfCode.Day05 do
  def part1(input) do
    %{maps: maps, seeds: seeds} =
      input
      |> parse_input()

    seeds |> Enum.map(&get_location(maps, "seed", &1)) |> Enum.min()
  end

  def part2(_input) do
  end

  def parse_input(input) do
    [seeds | maps] = String.split(input, "\n\n", trim: true)

    seeds =
      seeds
      |> String.split(":", trim: true)
      |> List.last()
      |> String.split(" ", trim: true)
      |> Enum.map(fn seed -> String.trim(seed) |> String.to_integer() end)

    maps =
      Enum.map(maps, &parse_map/1)
      |> Enum.reduce(%{}, fn %{from: from, to: to, values: values}, acc ->
        Map.put_new(acc, from, %{to => values})
      end)

    %{seeds: seeds, maps: maps}
  end

  def parse_map(map) do
    [map_info | values] = String.split(map, "\n", trim: true)

    [from, _, to] =
      String.trim(map_info) |> String.split(" ") |> List.first() |> String.split("-")

    values = values |> Enum.map(&parse_value/1)

    %{from: from, to: to, values: values}
  end

  def calculate_shift(%{start_value: start, end_value: to, shift: shift}, value)
      when value >= start and value <= to,
      do: {:match, value - start + shift}

  def calculate_shift(_, _value), do: :nomatch

  def parse_value(value) do
    [x, y, z] = String.split(value, " ", trim: true) |> Enum.map(&String.to_integer/1)

    %{start_value: y, end_value: y + z - 1, shift: x}
  end

  def get_location(_, "location", value), do: value

  def get_location(map, current_state, current_value) do
    next_state = next_state(current_state)

    next_value =
      case get_in(map, [current_state, next_state]) do
        nil ->
          raise("something happened")

        [_ | _] = values ->
          Enum.map(values, &calculate_shift(&1, current_value))
          |> Enum.reject(&(&1 == :nomatch))
          |> case do
            [] -> current_value
            [{:match, value}] -> value
            _ -> raise "Something bad happened"
          end
      end

    # IO.puts("#{current_state}->#{next_state} : #{current_value}->#{next_value}")

    get_location(map, next_state, next_value)
  end

  @states ~w[seed soil fertilizer water light temperature humidity location]
  @states_indexed Enum.with_index(@states)

  def next_state("location"), do: nil

  def next_state(current_state) when current_state in @states,
    do:
      @states_indexed
      |> Enum.find(&(elem(&1, 0) == current_state))
      |> (&Enum.at(@states, elem(&1, 1) + 1)).()
end
