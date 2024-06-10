defmodule BrewPlotWeb.PlotComponents do
  use Phoenix.Component
  import BrewPlotWeb.CoreComponents

  def form_component(assigns) do
    ~H"""
    <.simple_form for={@form} phx-submit="save">
      <.input field={@form[:name]} label="Name" />
      <.input field={@form[:dataset_name]} label="Dataset" />
      <.input field={@form[:expression]} label="Expression" />
      <:actions>
        <.button>Save</.button>
      </:actions>
    </.simple_form>
    """
  end

  def plot_component(assigns) do
    ~H"""
    <div>
      <div id="brewery" phx-hook="RenderPlot" data-set={@plot_dataset}></div>
      <div>
        <%= unless @share do %>
          <.link navigate={"/plots/edit/#{@plot_id}"} class="px-5 text-blue-600">Edit</.link>
          <.link navigate="/plots" class="px-5 text-blue-600">List</.link>
          <.link navigate={"/plots/share/#{@plot_id}"} class="px-5 text-blue-600">Share</.link>
        <% end %>
      </div>
    </div>
    """
  end

  def share_form(assigns) do
    ~H"""
    <.simple_form for={@shared_plot_form} phx-submit="share">
      <.input field={@shared_plot_form[:email]} label="Email" />
      <:actions>
        <.button>Share</.button>
      </:actions>
    </.simple_form>
    """
  end
end
