defmodule BrewPlotWeb.PlotLive do
  alias BrewPlot.Brewery.Brew
  use BrewPlotWeb, :live_view
  alias BrewPlotWeb.PlotComponent
  alias BrewPlot.Brewery

  def mount(_params, _session, socket) do
    form = Brewery.change_plot() |> to_form()

    socket =
      socket
      |> assign(:form, form)
      |> assign(:plot_dataset, Jason.encode!([]))

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div>
      <aside
        id="default-sidebar"
        class="fixed top-0 left-0 z-40 w-64 h-screen transition-transform -translate-x-full sm:translate-x-0"
        aria-label="Sidebar"
      >
        <div class="h-full px-3 py-4 overflow-y-auto bg-gray-50 dark:bg-gray-800">
          <ul class="space-y-2 font-medium">
            <li>
              <a
                href="#"
                class="flex items-center p-2 text-gray-900 rounded-lg dark:text-white hover:bg-gray-100 dark:hover:bg-gray-700 group"
              >
                <span class="ms-3">Your Plots</span>
              </a>
            </li>
            <li>
              <a
                href="#"
                class="flex items-center p-2 text-gray-900 rounded-lg dark:text-white hover:bg-gray-100 dark:hover:bg-gray-700 group"
              >
                <span class="flex-1 ms-3 whitespace-nowrap">Shared with you</span>
              </a>
            </li>
          </ul>
        </div>
      </aside>
      <div>
        <.live_component
          id="renderplot"
          module={PlotComponent}
          form={@form}
          plot_dataset={@plot_dataset}
        />
      </div>
    </div>
    """
  end

  def handle_event("validate", unsigned_params, socket) do
    IO.inspect(unsigned_params)

    {:noreply, socket}
  end

  def handle_event(
        "save",
        %{"plot" => %{"dataset_name" => dataset_name, "expression" => expression}} = params,
        socket
      ) do
    IO.inspect(params)
    dataset = Brew.render_dataset(dataset_name)
    IO.inspect(dataset)

    data = Brewery.generate_dataset(dataset_name, expression)

    IO.inspect(data, label: "The data")
    socket = push_event(socket, "draw", %{set: data})
    socket = assign(socket, :plot_dataset, Jason.encode!(data))
    {:noreply, socket}
  end
end
