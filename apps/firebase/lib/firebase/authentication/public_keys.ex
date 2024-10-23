defmodule Firebase.Authentication.PublicKeys do
  @moduledoc """
  Fetches and stores google public keys needed to verify firebase tokens
  """
  use GenServer

  @env Mix.env()
  @minute 60 * 1000

  @test_pub_key """
  -----BEGIN PUBLIC KEY-----
  MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAyP5Q1+ZKmtFFON/V20Oj
  kKI+qCRXBDCMnEHgUAcjjH3IiXj9GTbkKSw+8BGNpDRzpMbEp43SZ/Ohb0dq3Qri
  mrKYUXUl4yDHfKJeJ2noEbq4A4cLYqXSnUddCGTyljdTZbTTNlLLmnq+Y/soo+d+
  8f7DlfW67ZJskpm+xJdBB3/8loXbvk1aGhw+6JEwWRSaTHnXdFclgrzxlSqX3/km
  QgNLcNGtuWrsGwTj3HD4eF44fF1zI00nnoflYHVIpLQsgA3pxWYJCrNhp0RJvTJh
  YfKJMH6gPfPPD5mreEMOSR38LQXMfxc6eKb6idk/qcC90PE+XQzWlh+So1ObezQy
  36sEwoQbW34biT4Wil7hy5J8CKHA1uA4/koPH2n1ga7X0+GBmm0dlwxS7c7jfzQh
  S57Bk0mlvqDYR0Be0ImcslHGIrhKifha074u+U4I+TyMR+VftcYwcQvsCaTb+OlJ
  WkvoTPUn3s4q2TAcHeitquBPBYvUnqFuzU4oBab3RaxyIjihhe0dg/dShl1xZlon
  fW/QiQPrc/m9hOJy/4zhN67TALL+UZwSI3kS2+1cLp2V5mXU9Xpnx7LWyY/Ueobz
  TE32XFg3qz8mGq6WDeoXBWnOALhUyA4DE4YAZogJqIitu9kstYv0wPWC9lBWzpLy
  +QtRXZdjtZbwODen6Q2nbrUCAwEAAQ==
  -----END PUBLIC KEY-----
  """

  def start_link(_) do
    GenServer.start_link(__MODULE__, @env, name: __MODULE__)
  end

  # TODO use ETS
  @doc """
  Fetches google public key for given kid
  """
  @spec fetch_key(String.t()) :: {:ok, String.t()} | :error
  def fetch_key(kid) do
    GenServer.call(__MODULE__, {:fetch_key, kid})
  end

  @impl true
  def init(:test) do
    {:ok, %{"test" => @test_pub_key}}
  end

  @impl true
  def init(_) do
    {:ok, %{}, {:continue, :after_init}}
  end

  @impl true
  def handle_continue(:after_init, old_state) do
    case Firebase.Authentication.Client.get_keys() do
      {:ok, public_keys, max_age} ->
        Process.send_after(self(), :refresh_keys, max_age)

        {:noreply, public_keys}

      :error ->
        {:noreply, old_state, {:continue, :after_init}}
    end
  end

  @impl true
  def handle_info(:refresh_keys, old_state) do
    case Firebase.Authentication.Client.get_keys() do
      {:ok, public_keys, max_age} ->
        Process.send_after(self(), :refresh_keys, max_age)

        {:noreply, public_keys}

      :error ->
        Process.send_after(self(), :refresh_keys, @minute)

        {:noreply, old_state}
    end
  end

  @impl true
  def handle_call({:fetch_key, kid}, _from, state) do
    {:reply, Map.fetch(state, kid), state}
  end
end
