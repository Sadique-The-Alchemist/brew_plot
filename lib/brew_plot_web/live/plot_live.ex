defmodule BrewPlotWeb.PlotLive do
  use BrewPlotWeb, :live_view
  alias BrewPlot.Brewery
  import BrewPlotWeb.PlotComponents
  alias BrewPlot.Vmodel

  def mount(%{"plot_id" => plot_id, "action" => "edit" = action}, _session, socket) do
    form = Brewery.change_plot(plot_id, %{}) |> to_form() |> Map.put(:action, action)
    plot = Brewery.get_plot(plot_id)
    vmodel = Vmodel.edit_plot(form, plot_id, action, plot)

    {:ok, assign(socket, :vmodel, vmodel)}
  end

  def mount(%{"action" => "new" = action}, _session, socket) do
    form = Brewery.change_plot() |> to_form() |> Map.put(:action, action)

    vmodel = Vmodel.new_plot(form, action)
    {:ok, assign(socket, :vmodel, vmodel)}
  end

  def mount(%{"plot_id" => plot_id, "action" => "share" = action}, _session, socket) do
    plot = Brewery.get_plot(plot_id)

    data = Brewery.generate_dataset(plot.dataset_name, plot.expression)

    socket = push_event(socket, "draw", %{set: data})
    data = Jason.encode!(data)
    shared_plot_form = Brewery.change_shared_plot() |> to_form()
    vmodel = Vmodel.share_plot(data, plot_id, action, plot, shared_plot_form)

    {:ok, assign(socket, :vmodel, vmodel)}
  end

  def mount(%{"action" => "shared", "plot_id" => "no_id"}, _session, socket) do
    plots = Brewery.shared_plots(socket.assigns.current_user.id)
    vmodel = Vmodel.shared_plots(plots)

    {:ok, assign(socket, :vmodel, vmodel)}
  end

  def mount(%{"action" => "shared", "plot_id" => plot_id}, _session, socket) do
    plot = Brewery.get_plot(plot_id)

    data = Brewery.generate_dataset(plot.dataset_name, plot.expression)
    socket = push_event(socket, "draw", %{set: data})
    data = Jason.encode!(data)
    vmodel = Vmodel.view_shared_plot(data)

    {:ok, assign(socket, :vmodel, vmodel)}
  end

  def mount(%{"plot_id" => plot_id}, _session, socket) do
    plot = Brewery.get_plot(plot_id)

    data = Brewery.generate_dataset(plot.dataset_name, plot.expression)
    socket = push_event(socket, "draw", %{set: data})
    data = Jason.encode!(data)

    vmodel = Vmodel.view_plot(data, plot_id, plot)
    {:ok, assign(socket, :vmodel, vmodel)}
  end

  def mount(_params, _session, socket) do
    plots = Brewery.list_plots(socket.assigns.current_user.id)
    vmodel = Vmodel.list_plots(plots)

    {:ok, assign(socket, :vmodel, vmodel)}
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
        <%= if @vmodel.list do %>
          <.table id="plots" rows={@vmodel.plots}>
            <:col :let={plot} label="Name"><%= plot.name %></:col>
            <:col :let={plot} label="Dataset Name"><%= plot.dataset_name %></:col>
            <:col :let={plot} label="Expression">
              <%= if @vmodel.share do %>
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
              <%= unless @vmodel.share do %>
                <.button phx-click="delete" value={plot.id}>Delete</.button>
              <% end %>
            </:col>
          </.table>
          <%= unless @vmodel.share do %>
            <.link navigate="/plots/new/no_id" class="text-blue-600">New</.link>
          <% end %>
        <% end %>
        <%= if @vmodel.plot_dataset do %>
          <.plot_component vmodel={@vmodel} />
        <% end %>
        <%= if @vmodel.form do %>
          <.form_component vmodel={@vmodel} />
        <% end %>
        <%= if @vmodel.shared_plot_form do %>
          <.share_form vmodel={@vmodel} />
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
      |> handle_action(socket.assigns.vmodel.action, socket)
      |> case do
        {:ok, plot} ->
          data = Brewery.generate_dataset(plot.dataset_name, plot.expression)
          socket = push_event(socket, "draw", %{set: data})
          data = Jason.encode!(data)
          vmodel = Vmodel.view_plot(data, plot.id, plot)

          put_flash(socket, :info, "Saved successfully")
          |> assign(:vmodel, vmodel)

        {:error, changeset} ->
          form = to_form(changeset)
          vmodel = Vmodel.error_changeset(socket.assigns.vmodel, form)
          put_flash(socket, :error, "Something went wrong") |> assign(:vmodel, vmodel)
      end

    {:noreply, socket}
  end

  def handle_event("share", %{"shared_plot" => %{"email" => email}}, socket) do
    socket =
      case Brewery.share_plot(email, socket.assigns.vmodel.plot_id) do
        {:ok, _shared_plot} ->
          vmodel = socket.assigns.vmodel |> Map.put(:shared_plot_form, false)
          socket |> put_flash(:info, "Shared succesfully") |> assign(:vmodel, vmodel)

        {:error, changeset} ->
          form = changeset |> to_form()
          vmodel = socket.assigns.vmodel

          vmodel =
            Vmodel.share_plot(
              vmodel.plot_dataset,
              vmodel.plot.id,
              vmodel.action,
              vmodel.plot,
              form
            )

          socket
          |> put_flash(:error, "Something went wrong")
          |> assign(:vmodel, vmodel)
      end

    {:noreply, socket}
  end

  def handle_event("delete", %{"value" => id}, socket) do
    id |> String.to_integer() |> Brewery.delete_plot()
    plots = Brewery.list_plots(socket.assigns.current_user.id)

    vmodel = Vmodel.list_plots(plots)

    {:noreply, assign(socket, :vmodel, vmodel)}
  end

  defp handle_action(attrs, "new", _socket) do
    Brewery.create_plot(attrs)
  end

  defp handle_action(attrs, "edit", socket) do
    Brewery.update_plot(socket.assigns.vmodel.plot, attrs)
  end
end
