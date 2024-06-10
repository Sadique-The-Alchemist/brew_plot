defmodule BrewPlotWeb.PlotLive do
  use BrewPlotWeb, :live_view
  alias BrewPlot.Brewery
  import BrewPlotWeb.PlotComponents

  def mount(%{"plot_id" => plot_id, "action" => "edit" = action}, _session, socket) do
    form = Brewery.change_plot(plot_id, %{}) |> to_form() |> Map.put(:action, action)
    plot = Brewery.get_plot(plot_id)

    socket =
      socket
      |> assign(:plot_dataset, false)
      |> assign(:list, false)
      |> assign(:form, form)
      |> assign(:plot_id, plot_id)
      |> assign(:action, action)
      |> assign(:plot, plot)
      |> assign(:share, false)
      |> assign(:shared_plot_form, false)

    {:ok, socket}
  end

  def mount(%{"action" => "new" = action}, _session, socket) do
    form = Brewery.change_plot() |> to_form() |> Map.put(:action, action)

    socket =
      socket
      |> assign(:plot_dataset, false)
      |> assign(:list, false)
      |> assign(:form, form)
      |> assign(:plot_id, false)
      |> assign(:action, action)
      |> assign(:plot, false)
      |> assign(:share, false)
      |> assign(:shared_plot_form, false)

    {:ok, socket}
  end

  def mount(%{"plot_id" => plot_id, "action" => "share" = action}, _session, socket) do
    plot = Brewery.get_plot(plot_id)

    data = Brewery.generate_dataset(plot.dataset_name, plot.expression)

    socket = push_event(socket, "draw", %{set: data})
    data = Jason.encode!(data)
    shared_plot_form = Brewery.change_shared_plot() |> to_form()

    socket =
      socket
      |> assign(:plot_dataset, data)
      |> assign(:list, false)
      |> assign(:form, false)
      |> assign(:plot_id, plot_id)
      |> assign(:action, action)
      |> assign(:plot, plot)
      |> assign(:share, false)
      |> assign(:shared_plot_form, shared_plot_form)

    {:ok, socket}
  end

  def mount(%{"action" => "shared", "plot_id" => "no_id"}, _session, socket) do
    plots = Brewery.shared_plots(socket.assigns.current_user.id)

    socket =
      socket
      |> assign(:form, false)
      |> assign(:plots, plots)
      |> assign(:list, true)
      |> assign(:plot_dataset, false)
      |> assign(:plot_id, false)
      |> assign(:action, false)
      |> assign(:share, true)
      |> assign(:shared_plot_form, false)

    {:ok, socket}
  end

  def mount(%{"action" => "shared", "plot_id" => plot_id}, _session, socket) do
    plot = Brewery.get_plot(plot_id)

    data = Brewery.generate_dataset(plot.dataset_name, plot.expression)
    socket = push_event(socket, "draw", %{set: data})
    data = Jason.encode!(data)

    socket =
      socket
      |> assign(:form, false)
      |> assign(:plots, false)
      |> assign(:list, false)
      |> assign(:plot_dataset, data)
      |> assign(:plot_id, false)
      |> assign(:action, false)
      |> assign(:share, true)
      |> assign(:shared_plot_form, false)

    {:ok, socket}
  end

  def mount(%{"plot_id" => plot_id}, _session, socket) do
    plot = Brewery.get_plot(plot_id)

    data = Brewery.generate_dataset(plot.dataset_name, plot.expression)
    socket = push_event(socket, "draw", %{set: data})
    data = Jason.encode!(data)

    socket =
      socket
      |> assign(:plot_dataset, data)
      |> assign(:list, false)
      |> assign(:form, false)
      |> assign(:plot_id, plot_id)
      |> assign(:action, false)
      |> assign(:plot, plot)
      |> assign(:share, false)
      |> assign(:shared_plot_form, false)

    {:ok, socket}
  end

  def mount(_params, _session, socket) do
    plots = Brewery.list_plots(socket.assigns.current_user.id)

    socket =
      socket
      |> assign(:form, false)
      |> assign(:plots, plots)
      |> assign(:list, true)
      |> assign(:plot_dataset, false)
      |> assign(:plot_id, false)
      |> assign(:action, false)
      |> assign(:share, false)
      |> assign(:shared_plot_form, false)

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
                href="/plots"
                class="flex items-center p-2 text-gray-900 rounded-lg dark:text-white hover:bg-gray-100 dark:hover:bg-gray-700 group"
              >
                <span class="ms-3">Your Plots</span>
              </a>
            </li>
            <li>
              <a
                href="/plots/shared/no_id"
                class="flex items-center p-2 text-gray-900 rounded-lg dark:text-white hover:bg-gray-100 dark:hover:bg-gray-700 group"
              >
                <span class="flex-1 ms-3 whitespace-nowrap">Shared with you</span>
              </a>
            </li>
          </ul>
        </div>
      </aside>
      <div>
        <%= if @list do %>
          <.table id="plots" rows={@plots}>
            <:col :let={plot} label="Name"><%= plot.name %></:col>
            <:col :let={plot} label="Dataset Name"><%= plot.dataset_name %></:col>
            <:col :let={plot} label="Expression">
              <%= if @share do %>
                <.link navigate={"#{plot.id}"} class="text-blue-600">
                  <%= plot.expression %>
                </.link>
              <% else %>
                <.link navigate={"/plots/#{plot.id}"} class="text-blue-600">
                  <%= plot.expression %>
                </.link>
              <% end %>
            </:col>

            <:col :let={plot} label="">
              <%= unless @share do %>
                <.button phx-click="delete" value={plot.id}>Delete</.button>
              <% end %>
            </:col>
          </.table>
          <%= unless @share do %>
            <.link navigate="/plots/new/no_id" class="text-blue-600">New</.link>
          <% end %>
        <% end %>
        <%= if @plot_dataset do %>
          <.plot_component plot_dataset={@plot_dataset} plot_id={@plot_id} share={@share} />
        <% end %>
        <%= if @form do %>
          <.form_component form={@form} action={@action} />
        <% end %>
        <%= if @shared_plot_form do %>
          <.share_form shared_plot_form={@shared_plot_form} action={@action} />
        <% end %>
      </div>
    </div>
    """
  end

  def handle_event(
        "save",
        %{"plot" => attrs},
        socket
      ) do
    socket =
      attrs
      |> Map.put("user_id", socket.assigns.current_user.id)
      |> handle_action(socket.assigns.form.action, socket)
      |> case do
        {:ok, plot} ->
          data = Brewery.generate_dataset(plot.dataset_name, plot.expression)
          socket = push_event(socket, "draw", %{set: data})
          data = Jason.encode!(data)

          put_flash(socket, :info, "Saved successfully")
          |> assign(:plot_dataset, data)
          |> assign(:form, false)
          |> assign(:plot_id, plot.id)

        {:error, changeset} ->
          put_flash(socket, :error, "Something went wrong") |> assign(:form, to_form(changeset))
      end

    {:noreply, socket}
  end

  def handle_event("share", %{"shared_plot" => %{"email" => email}}, socket) do
    socket =
      case Brewery.share_plot(email, socket.assigns.plot_id) do
        {:ok, _shared_plot} ->
          socket |> put_flash(:info, "Shared succesfully") |> assign(:shared_plot_form, false)

        {:error, changeset} ->
          socket
          |> put_flash(:error, "Something went wrong")
          |> assign(:shared_plot_form, changeset |> to_form())
      end

    {:noreply, socket}
  end

  def handle_event("delete", %{"value" => id}, socket) do
    id |> String.to_integer() |> Brewery.delete_plot()
    plots = Brewery.list_plots(socket.assigns.current_user.id)

    socket =
      socket
      |> assign(:form, false)
      |> assign(:plots, plots)
      |> assign(:list, true)
      |> assign(:plot_dataset, false)
      |> assign(:plot_id, false)
      |> assign(:action, false)

    {:noreply, socket}
  end

  defp handle_action(attrs, "new", _socket) do
    Brewery.create_plot(attrs)
  end

  defp handle_action(attrs, "edit", socket) do
    Brewery.update_plot(socket.assigns.plot, attrs)
  end
end
