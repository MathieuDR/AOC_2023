defmodule AdventOfCode.Day10 do
  def part1(_args) do
  end

  def part2(_args) do
  end

  @symbols [?|, ?-, ?L, ?J, ?7, ?F, ?., ?S]
  @symbols_translated [[:n, :s], [:e, :w], [:n, :e], [:n, :w], [:s, :w], [:e, :s], [], [:start]]
  @symbol_map Enum.zip(@symbols, @symbols_translated) |> Map.new()

  @coord_map %{:e => {1, 0}, :n => {0, 1}, :s => {0, -1}, :w => {-1, 0}}

  def parse(string, x \\ 0, y \\ 0, acc \\ %{})
  def parse("", _x, _y, acc), do: acc
  def parse(<<?\n>> <> rest, _x, y, acc), do: parse(rest, 0, y + 1, acc)
  def parse(<<?.>> <> rest, x, y, acc), do: parse(rest, x + 1, y, acc)

  def parse(<<c>> <> rest, x, y, acc) do
    value = @symbol_map[c]
    acc = Map.update(acc, y, %{x => value}, &Map.put_new(&1, x, value))
    parse(rest, x + 1, y, acc)
  end

  def find_connections(map, {x, y} = current_coord) do
    curr = map[y][x]

    get_coords(curr)
    |> apply_coords(current_coord)
  end

  def apply_coords(coords, {x, y}), do: Enum.map(coords, fn {dx, dy} -> {x + dx, y + dy} end)

  def get_coords([]), do: []
  def get_coords([coord | rest]), do: [@coord_map[coord] | get_coords(rest)]
end
