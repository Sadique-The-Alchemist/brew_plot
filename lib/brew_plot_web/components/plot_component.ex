defmodule BrewPlotWeb.PlotComponent do
  use BrewPlotWeb, :live_component
  import BrewPlotWeb.PlotComponents

  def render(assigns) do
    ~H"""
    <div>
      <.form_component form={@form} />
      <.plot_component plot_dataset={@plot_dataset} />
    </div>
    """
  end
end
