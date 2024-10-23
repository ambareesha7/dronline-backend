defmodule Authentication.Random do
  @spec url_safe(non_neg_integer) :: String.t()
  def url_safe(size \\ 20) do
    random_part(size) <> datetime_part()
  end

  defp random_part(size) do
    size
    |> :crypto.strong_rand_bytes()
    |> Base.encode64(case: :lower)
    |> Base.url_encode64(case: :lower, padding: false)
  end

  defp datetime_part do
    DateTime.utc_now()
    |> DateTime.to_unix()
    |> to_string()
    |> Base.encode64(case: :lower)
    |> Base.url_encode64(case: :lower, padding: false)
  end
end
