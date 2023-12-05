defmodule AdventOfCode.Day03 do
  def part1(args) do
    args
    |> input_to_map()
    |> get_numbers_touching_symbols()
    |> Enum.sum()
  end

  def part2(args) do
    args |> input_to_map() |> get_gear_ratios |> Enum.sum()
  end

  def input_to_map(input) do
    String.split(input)
    |> Enum.with_index(fn line, index -> {index, line_to_map(line)} end)
    |> Enum.reduce(%{}, fn {index, line_map}, acc ->
      Map.put(acc, index, line_map)
    end)
  end

  def line_to_map(line), do: line_to_map(line, 0, %{acc: "", symbols: [], gears: []})

  def line_to_map(<<i>> <> rest, pos, %{acc: acc} = result) when i in ?0..?9 do
    acc = acc <> <<i>>
    line_to_map(rest, pos + 1, %{result | acc: acc})
  end

  def line_to_map("", pos, result) do
    result =
      case Map.get(result, :acc) do
        "" -> result
        number -> add_acc_to_result(pos, number, result)
      end

    Map.drop(result, [:acc])
  end

  def line_to_map(<<char>> <> rest, pos, %{acc: ""} = result) do
    result = maybe_add_symbol(char, pos, result)
    line_to_map(rest, pos + 1, result)
  end

  def line_to_map(<<char>> <> rest, pos, %{acc: number} = result) do
    result = add_acc_to_result(pos, number, result)
    result = maybe_add_symbol(char, pos, result)
    line_to_map(rest, pos + 1, %{result | acc: ""})
  end

  def add_acc_to_result(pos, number, result) do
    ln = String.length(number)
    value = String.to_integer(number)

    Enum.reduce((pos - ln)..(pos - 1), result, &Map.put(&2, &1, {pos - ln, value}))
  end

  def get_numbers_touching_symbols(board) do
    Map.keys(board)
    |> Enum.reduce([], fn y, acc ->
      acc ++ Enum.flat_map(board[y][:symbols], fn x -> get_surrounding_numbers({x, y}, board) end)
    end)
    |> Enum.uniq()
    |> Enum.map(&elem(&1, 2))
  end

  def get_gear_ratios(board) do
    Map.keys(board)
    |> Enum.reduce([], fn y, acc ->
      acc ++
        Enum.flat_map(board[y][:gears], fn x ->
          case get_surrounding_numbers({x, y}, board) do
            [{_x, _y, n1}, {_, _, n2}] -> [n1 * n2]
            _ -> []
          end
        end)
    end)
  end

  def get_numbers({x, y} = coords, board) do
    case read_from_board(coords, board) do
      nil -> [read_from_board({x - 1, y}, board), read_from_board({x + 1, y}, board)]
      value -> [value]
    end
  end

  def get_surrounding_numbers({x, y}, board) do
    (get_numbers({x, y + 1}, board) ++
       get_numbers({x, y}, board) ++ get_numbers({x, y - 1}, board))
    |> Enum.reject(&is_nil/1)
  end

  def read_from_board({x, y}, board),
    do: board[y][x] |> maybe_add_y(y)

  def maybe_add_y(nil, _), do: nil
  def maybe_add_y({start, value}, y), do: {y, start, value}

  defp maybe_add_symbol(?., _pos, result), do: result

  defp maybe_add_symbol(?*, pos, result) do
    {_, result} = Map.get_and_update(result, :gears, &{&1, [pos | &1]})
    {_, result} = Map.get_and_update(result, :symbols, &{&1, [pos | &1]})

    result
  end

  defp maybe_add_symbol(_, pos, result),
    do: Map.get_and_update(result, :symbols, &{&1, [pos | &1]}) |> elem(1)
end
