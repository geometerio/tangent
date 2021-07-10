defmodule Test.Support.Helpers do
  @moduledoc false
  # borrowed from https://github.com/patricksrobertson/secure_random.ex
  use Bitwise

  @default_length 16

  @doc """
  Returns UUID v4 string. I have lifted most of this straight from Ecto's implementation.
  ## Examples
    iex> SecureRandom.uuid
    "e1d87f6e-fbd5-6801-9528-a1d568c1fd02"
  """
  def uuid do
    bigenerate() |> encode
  end

  @doc """
  Returns random bytes.
  ## Examples
      iex> SecureRandom.random_bytes
      <<202, 104, 227, 197, 25, 7, 132, 73, 92, 186, 242, 13, 170, 115, 135, 7>>
      iex> SecureRandom.random_bytes(8)
      <<231, 123, 252, 174, 156, 112, 15, 29>>
  """
  def random_bytes(n \\ @default_length) do
    :crypto.strong_rand_bytes(n)
  end

  defp bigenerate do
    <<u0::48, _::4, u1::12, _::2, u2::62>> = random_bytes(16)
    <<u0::48, 4::4, u1::12, 2::2, u2::62>>
  end

  defp encode(<<u0::32, u1::16, u2::16, u3::16, u4::48>>) do
    hex_pad(u0, 8) <>
      "-" <>
      hex_pad(u1, 4) <>
      "-" <>
      hex_pad(u2, 4) <>
      "-" <>
      hex_pad(u3, 4) <>
      "-" <>
      hex_pad(u4, 12)
  end

  defp hex_pad(hex, count) do
    hex = Integer.to_string(hex, 16)
    lower(hex, :binary.copy("0", count - byte_size(hex)))
  end

  defp lower(<<h, t::binary>>, acc) when h in ?A..?F,
    do: lower(t, acc <> <<h + 32>>)

  defp lower(<<h, t::binary>>, acc),
    do: lower(t, acc <> <<h>>)

  defp lower(<<>>, acc),
    do: acc
end
