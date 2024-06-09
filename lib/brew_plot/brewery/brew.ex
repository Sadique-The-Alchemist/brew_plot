defmodule BrewPlot.Brewery.Brew do
  require Logger
  use GenServer
  @filename_url "https://api.github.com/repos/plotly/datasets/git/trees/master"
  @data_url "https://raw.githubusercontent.com/plotly/datasets/master/"
  @file_format ".csv"
  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def init(init_arg) do
    Logger.info("Initializing genserver")
    {:ok, init_arg, {:continue, :load}}
  end

  def handle_continue(:load, state) do
    Logger.info("Loading filenames")
    filenames = load_filenames()
    :ets.new(:datasets, [:set, :protected, :named_table])
    {:noreply, Map.put(state, "filenames", filenames)}
  end

  def render_dataset(filename) do
    GenServer.call(__MODULE__, {:dataset, filename})
  end

  def valid_files() do
    GenServer.call(__MODULE__, :valid_filenames)
  end

  def handle_call(:valid_filenames, _from, state) do
    filenames = Map.get(state, "filenames")
    {:reply, filenames, state}
  end

  def handle_call({:dataset, filename}, _from, state) do
    dataset =
      case :ets.lookup(:datasets, filename) do
        [{^filename, dataset}] ->
          dataset

        _ ->
          dataset = load_dataset(filename)
          :ets.insert(:datasets, {filename, dataset})
          dataset
      end

    {:reply, dataset, state}
  end

  # Load dataset from URL

  def load_dataset(filename) do
    Finch.build(
      :get,
      @data_url <> filename <> @file_format
    )
    |> Finch.request(BrewPlot.Finch)
    |> elem(1)
    |> Map.get(:body)
    |> String.split("\n")
    |> Enum.map(&String.split(&1, ","))
    |> convert_to_map()
  end

  # Convert dataset to map with headers as keys

  def convert_to_map(dataset) do
    {keys, values} = List.pop_at(dataset, 0)

    Enum.reduce(values, %{}, fn value, acc ->
      Enum.reduce(0..(length(keys) - 1), %{}, fn index, iacc ->
        key = Enum.at(keys, index)
        ex = Map.get(acc, key, [])
        val = [Enum.at(value, index) | ex] |> Enum.filter(fn x -> not is_nil(x) end)
        Map.put(iacc, key, val)
      end)
    end)
    |> Enum.reduce(%{}, fn {key, value}, acc ->
      value = Enum.reverse(value)
      Map.put(acc, key, value)
    end)
  end

  defp load_filenames() do
    Finch.build(:get, @filename_url)
    |> Finch.request(BrewPlot.Finch)
    |> elem(1)
    |> then(&Jason.decode!(&1.body))
    |> Map.get("tree")
    |> Enum.filter(&String.contains?(&1["path"], ".csv"))
    |> Enum.map(& &1["path"])
  end
end
