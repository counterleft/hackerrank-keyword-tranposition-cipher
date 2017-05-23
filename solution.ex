defmodule Cipher do
  @alphabet "ABCDEFGHIJKLMNOPQRSTUVWXYZ"

  defstruct decodebook: %{}

  def decode(cipher, encoded) do
    encoded
    |> String.upcase
    |> String.split("", trim: true)
    |> Enum.map(fn(e) -> Map.get(cipher.decodebook, e, " ") end)
    |> Enum.join
  end

  def new(keyword) do
    normalize_keyword(keyword)
    |> normalize_alphabet(@alphabet)
    |> substitution_alphabet
    |> new_decodebook(@alphabet)
    |> (&%Cipher{decodebook: &1}).()
  end

  defp normalize_keyword(keyword) do
    keyword
    |> String.upcase
    |> String.split("", trim: true)
    |> Enum.uniq
  end

  defp normalize_alphabet(normalized_keyword, alphabet) do
    alphabet
    |> String.split("", trim: true)
    |> Enum.reject(fn(letter) -> Enum.member?(normalized_keyword, letter) end)
    |> (&{normalized_keyword ++ &1, length(normalized_keyword)}).()
  end

  defp substitution_alphabet({normalized_alphabet, keyword_length}) do
    normalized_alphabet
    |> Enum.chunk(keyword_length, keyword_length, [])
    |> Enum.map(&fill(&1, keyword_length, nil))
    |> transpose
    |> Enum.map(&(Enum.filter(&1, fn(e) -> !is_nil(e) end)))
    |> Enum.sort
    |> List.flatten
  end

  defp new_decodebook(substitution_alphabet, alphabet) do
    substitution_alphabet
    |> Enum.zip(String.split(alphabet, "", trim: true))
    |> Map.new
  end

  defp fill(list, size, _) when length(list) >= size, do: list
  defp fill(list, size, filler) when length(list) < size do
    Enum.reduce(1..(size - length(list)), list, fn(_, acc) ->
      List.insert_at(acc, -1, filler)
    end)
  end

  defp transpose(list) do
    list
    |> Enum.zip
    |> Enum.map(&Tuple.to_list(&1))
  end
end

defmodule Solution do
  def solve do
    n = IO.gets("") |> String.trim |> String.to_integer
    Enum.each(1..n, fn(_) ->
      keyword = IO.gets("") |> String.trim
      encoded = IO.gets("") |> String.trim

      Cipher.new(keyword)
      |> Cipher.decode(encoded)
      |> IO.puts
    end)
  end
end

Solution.solve()