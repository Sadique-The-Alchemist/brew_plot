defmodule BrewPlot.Brewery do
  alias BrewPlot.Repo
  alias BrewPlot.Brewery.Plot
  alias BrewPlot.Brewery.Brew
  @arithmetic_expressions ["+", "-", "*", "/"]

  # @data_url "https://raw.githubusercontent.com/plotly/datasets/master/wind_speed_laurel_nebraska.csv"
  # @filename_url "https://api.github.com/repos/plotly/datasets/git/trees/master"
  # # @data_url "https://api.github.com/repos/plotly/datasets/contents/wind_speed_laurel_nebraska.csv"

  def change_plot(attrs \\ %{}) do
    %Plot{}
    |> Plot.changeset(attrs)
  end

  def create_plot(changeset) do
    Repo.insert(changeset)
  end

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

  # defp transpose([[] | _]), do: []

  # defp transpose(m) do
  #   [Enum.map(m, &hd/1) | transpose(Enum.map(m, &tl/1))]
  # end

  defp flotify_data(dataset, field) do
    Map.get(dataset, field)
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

  # defp evaluate_expression(expressions) do
  #   expressions
  #   |> Enum.map(fn expression ->
  #     Enum.reduce(expression, {}, fn value, acc ->
  #       if is_integer(value) do
  #         Tuple.append(acc, value)
  #       end
  #       if value in @arithmetic_expressions
  #       calculate(acc, value)
  #     end)
  #   end)
  # end

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
