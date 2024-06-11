defmodule BrewPlot.Vmodel do
  defstruct plot_dataset: false,
            list: false,
            form: false,
            plot_id: false,
            action: false,
            plot: false,
            plots: false,
            share: false,
            shared_plot_form: false

  @type t() :: %__MODULE__{
          plot_dataset: String.t() | boolean(),
          list: boolean(),
          form: any(),
          plot_id: integer() | boolean(),
          action: String.t() | boolean(),
          plot: any(),
          plots: list() | boolean(),
          share: boolean(),
          shared_plot_form: any()
        }
  def edit_plot(form, plot_id, action, plot) do
    %BrewPlot.Vmodel{
      form: form,
      plot_id: plot_id,
      action: action,
      plot: plot
    }
  end

  def new_plot(form, action) do
    %BrewPlot.Vmodel{
      form: form,
      action: action
    }
  end

  def share_plot(data, plot_id, action, plot, shared_plot_form) do
    %BrewPlot.Vmodel{
      plot_dataset: data,
      plot_id: plot_id,
      action: action,
      plot: plot,
      shared_plot_form: shared_plot_form
    }
  end

  def view_shared_plot(plot_dataset) do
    %BrewPlot.Vmodel{
      plot_dataset: plot_dataset,
      share: true
    }
  end

  def view_plot(plot_dataset, plot_id, plot) do
    %BrewPlot.Vmodel{
      plot_dataset: plot_dataset,
      plot_id: plot_id,
      plot: plot
    }
  end

  def list_plots(plots) do
    %BrewPlot.Vmodel{
      plots: plots,
      list: true
    }
  end

  def shared_plots(plots) do
    %BrewPlot.Vmodel{
      plots: plots,
      list: true,
      share: true
    }
  end

  def error_changeset(%__MODULE__{plot: plot, action: "edit" = action}, form) do
    edit_plot(form, plot.id, action, plot)
  end

  def error_changeset(%__MODULE__{action: "new" = action}, form) do
    new_plot(form, action)
  end

  def error_changeset(vmodel, form), do: Map.merge(vmodel, %{form: form})
end
