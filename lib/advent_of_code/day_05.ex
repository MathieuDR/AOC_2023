defmodule AdventOfCode.Day05 do
  def part1(input) do
    %{maps: maps, seeds: seeds} =
      input
      |> parse_input()

    seeds |> Enum.map(&get_location(maps, "seed", &1)) |> Enum.min()
  end

  def part2(input) do
    %{maps: maps, seeds: seeds} =
      input
      |> parse_input()

    seeds =
      seeds
      |> Enum.chunk_every(2)
      |> Enum.map(fn [start, count] -> start..(start + count - 1) end)

    seed_to_location =
      get_in(maps, ["humidity", "location"])
      |> Enum.sort_by(& &1[:destination_range_start])
      |> Enum.map(fn %{destination_range_start: x, destination_range_end: y} ->
        {x..y, get_seed_range(maps, "location", [x..y])}
      end)

    seed_to_location
    |> Enum.find(fn {location_range, seed_ranges} ->
      seed_ranges
      |> Enum.with_index()
      |> Enum.find(fn {seed_range, idx} ->
        seeds
        |> Enum.find(&(Range.disjoint?(&1, seed_range) == false))
      end)
    end)
  end

  # %{
  #     source_range_start: y,
  #     source_range_end: y + z - 1,
  #   destination_range_start: x,
  #     destination_range_end: x + z - 1
  # }

  def get_seed_range(_map, "seed", ranges), do: ranges

  def get_seed_range(map, current_state, ranges) do
    previous_state = previous_state(current_state)

    state_map = get_in(map, [previous_state, current_state])

    ranges =
      Enum.flat_map(ranges, fn range ->
        Enum.reduce(state_map, {[], range}, fn
          _, {_ranges, nil} = result ->
            result

          %{
            source_range_start: srs,
            source_range_end: _sre,
            destination_range_start: drs,
            destination_range_end: dre
          },
          {source_ranges, current_range} ->
            {intersect, rest} = calculate_range_info(current_range, drs..dre)
            # |> IO.inspect(label: "stuff")

            intersect =
              case intersect do
                nil -> nil
                x..y -> (srs - drs + x)..(srs - drs + y)
              end

            # |> IO.inspect(label: "after shift")

            {[intersect | source_ranges], rest}
        end)
        # |> IO.inspect(label: "before then")
        |> then(fn {source_ranges, current_range} -> [current_range | source_ranges] end)
        |> Enum.reject(&is_nil/1)
      end)

    get_seed_range(map, previous_state, ranges)
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

  def calculate_shift(
        %{source_range_start: start, source_range_end: to, destination_range_start: shift},
        value
      )
      when value >= start and value <= to,
      do: {:match, value - start + shift}

  def calculate_shift(_, _value), do: :nomatch

  def parse_value(value) do
    [x, y, z] = String.split(value, " ", trim: true) |> Enum.map(&String.to_integer/1)

    %{
      source_range_start: y,
      source_range_end: y + z - 1,
      destination_range_start: x,
      destination_range_end: x + z - 1
    }
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

  def calculate_range_info(r1, r2), do: {get_intersection(r1, r2), get_leftover(r1, r2)}

  def get_leftover(x1..y1, x2.._y2) when y1 < x2, do: x1..y1
  def get_leftover(x1..y1, _x2..y2) when x1 > y2, do: x1..y1
  def get_leftover(x1..y1, x2..y2) when x1 >= x2 and y1 <= y2, do: nil
  def get_leftover(x1..y1, x2..y2) when x1 < x2 and y1 > y2, do: x2..y2
  def get_leftover(x1.._y1, x2.._y2) when x1 < x2, do: x1..(x2 - 1)
  def get_leftover(_x1..y1, _x2..y2) when y1 > y2, do: (y2 + 1)..y1

  def get_intersection(x1..y1 = r1, x2..y2 = r2) do
    case Range.disjoint?(r1, r2) do
      true -> nil
      _ -> max(x1, x2)..min(y1, y2)
    end
  end

  @states ~w[seed soil fertilizer water light temperature humidity location]
  @states_indexed Enum.with_index(@states)

  def previous_state("seed"), do: nil

  def previous_state(current_state) when current_state in @states,
    do:
      @states_indexed
      |> Enum.find(&(elem(&1, 0) == current_state))
      |> (&Enum.at(@states, elem(&1, 1) - 1)).()

  def next_state("location"), do: nil

  def next_state(current_state) when current_state in @states,
    do:
      @states_indexed
      |> Enum.find(&(elem(&1, 0) == current_state))
      |> (&Enum.at(@states, elem(&1, 1) + 1)).()
end
