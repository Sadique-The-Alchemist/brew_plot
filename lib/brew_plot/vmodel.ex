defmodule BrewPlot.Vmodel do
  defstruct [:plot_dataset, :list, :form, :plot_id, :action, :plot, :share, :shared_plot_form]
  def edit_plot(form, plot_id, action, plot) do
    %BrewPlot.Vmodel{
      plot_dataset: false,
      list: false,
      form: form,
      plot_id: plot_id,
      action: action,
      plot: plot,
      share: false,
      shared_plot_form: false
    }
  end
end
