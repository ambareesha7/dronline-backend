defmodule Firebase.DynamicLinks.BackendMock do
  def generate(_, _) do
    {:ok, %Tesla.Env{status: 200, body: %{"shortLink" => "#{:rand.uniform(1_000_000)}"}}}
  end
end
