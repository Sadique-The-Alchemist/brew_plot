defmodule BrewPlotWeb.PlotComponents do
  use Phoenix.Component
  import BrewPlotWeb.CoreComponents

  def form_component(assigns) do
    ~H"""
    <.simple_form for={@form} phx-change="validate" phx-submit="save">
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
    <div id="brewery" phx-hook="RenderPlot" data-set={@plot_dataset}></div>
    """
  end
end
