defmodule Cipher do
  @alphabet "ABCDEFGHIJKLMNOPQRSTUVWXYZ"

  def decode(keyword, encoded) do
    cipher = new_cipher(keyword, @alphabet)

    encoded
    |> String.upcase
    |> String.split("", trim: true)
    |> Enum.map(fn(e) -> Map.get(cipher, e, " ") end)
    |> Enum.join
  end

  defp new_cipher(keyword, alphabet) do
    normalize_keyword(keyword)
    |> normalize_alphabet(@alphabet)
    |> substitution_alphabet
    |> Enum.zip(String.split(alphabet, "", trim: true))
    |> Map.new
  end

  defp normalize_keyword(keyword) do
    keyword
    |> String.upcase
    |> String.split("", trim: true)
    |> Enum.uniq
    |> Enum.join
  end

  defp normalize_alphabet(normalized_keyword, alphabet) do
    keyword_list = String.split(normalized_keyword, "", trim: true)

    normalized_alphabet = alphabet
    |> String.split("")
    |> Enum.reject(fn(letter) -> Enum.member?(keyword_list, letter) end)
    |> Enum.join

    {normalized_keyword, normalized_alphabet}
  end

  defp substitution_alphabet({normalized_keyword, normalized_alphabet}) do
    size = String.length(normalized_keyword)

    String.split(normalized_keyword <> normalized_alphabet, "", trim: true)
    |> Enum.chunk(size, size, [])
    |> Enum.map(&fill(&1, size, nil))
    |> transpose
    |> Enum.map(&(Enum.filter(&1, fn(e) -> !is_nil(e) end)))
    |> Enum.sort
    |> List.flatten
  end

  defp fill(list, size, filler) do
    case length(list) < size do
      true ->
        diff = size - length(list)
        Enum.reduce(1..diff, list, fn(_, acc) -> List.insert_at(acc, -1, filler) end)
      _ ->
        list
    end
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
      IO.puts Cipher.decode(keyword, encoded)
    end)
  end
end

Solution.solve()