defmodule BrewPlot.Brewery do
  alias BrewPlot.Repo
  alias BrewPlot.Brewery.Plot
  alias BrewPlot.Brewery.Brew
  alias BrewPlot.Brewery.SharedPlot
  alias BrewPlot.Accounts
  import Ecto.Query
  @arithmetic_expressions ["+", "-", "*", "/"]

  # @data_url "https://raw.githubusercontent.com/plotly/datasets/master/wind_speed_laurel_nebraska.csv"
  # @filename_url "https://api.github.com/repos/plotly/datasets/git/trees/master"
  # # @data_url "https://api.github.com/repos/plotly/datasets/contents/wind_speed_laurel_nebraska.csv"
  def list_plots(user_id) do
    from(p in Plot, where: p.user_id == ^user_id) |> Repo.all()
  end

  def change_plot(plot_id, attrs) do
    plot_id
    |> get_plot()
    |> Plot.changeset(attrs)
  end

  def delete_plot(id) do
    id
    |> get_plot()
    |> Repo.delete()
  end

  def change_plot(attrs \\ %{}) do
    %Plot{}
    |> Plot.changeset(attrs)
  end

  def create_plot(attrs) do
    %Plot{}
    |> Plot.changeset(attrs)
    |> Repo.insert()
  end

  def change_shared_plot(attrs \\ %{}) do
    %SharedPlot{}
    |> SharedPlot.changeset(attrs)
  end

  def share_plot(email, plot_id) do
    user = Accounts.get_user_by_email(email)

    attrs = %{"user_id" => user.id, "plot_id" => plot_id}

    %SharedPlot{}
    |> SharedPlot.changeset(attrs)
    |> Repo.insert()
  end

  def shared_plots(user_id) do
    from(p in Plot, join: sp in SharedPlot, on: p.id == sp.plot_id, where: sp.user_id == ^user_id)
    |> Repo.all()
  end

  def update_plot(plot, attrs) do
    plot
    |> Plot.changeset(attrs)
    |> Repo.update()
  end

  def get_plot(plot_id), do: Repo.get(Plot, plot_id)

  def generate_dataset(filename, expression) do
    dataset = Brew.render_dataset(filename)

    expression
    |> String.replace(@arithmetic_expressions, fn x -> ",#{x}," end)
    |> String.split(",")
    |> Enum.map(fn expression ->
      if expression in @arithmetic_expressions do
        expression
      else
        flotify_data(dataset, expression)
      end
    end)
    |> evaluate_expression()
  end

  defp evaluate_expression([data]), do: data

  defp evaluate_expression([lhs, operator, rhs]) do
    result(lhs, rhs, [], operator)
  end

  defp flotify_data(dataset, field) do
    Map.get(dataset, String.trim(field))
    |> Enum.filter(fn value -> String.length(value) > 0 end)
    |> Enum.map(fn value ->
      value =
        if String.contains?(value, ".") do
          value
        else
          value <> ".0"
        end

      String.to_float(value)
    end)
  end

  # Summing two lists together
  defp result(list1, list2, total \\ [], operator)

  defp result([], [], total, _operator) do
    Enum.reverse(total)
  end

  defp result([h1 | t1], [], total, _operator) do
    result(t1, [], [h1 | total])
  end

  defp result([], [h2 | t2], total, _operator) do
    result([], t2, [h2 | total])
  end

  defp result([h1 | t1], [h2 | t2], total, operator) do
    result(t1, t2, [calculate(h1, h2, operator) | total], operator)
  end

  def calculate(lhs, rhs, "+"), do: lhs + rhs
  def calculate(lhs, rhs, "-"), do: lhs - rhs
  def calculate(lhs, rhs, "*"), do: lhs * rhs
  def calculate(lhs, rhs, "/"), do: lhs / rhs
end
