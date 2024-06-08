defmodule BrewPlotWeb.ErrorJSONTest do
  use BrewPlotWeb.ConnCase, async: true

  test "renders 404" do
    assert BrewPlotWeb.ErrorJSON.render("404.json", %{}) == %{errors: %{detail: "Not Found"}}
  end

  test "renders 500" do
    assert BrewPlotWeb.ErrorJSON.render("500.json", %{}) ==
             %{errors: %{detail: "Internal Server Error"}}
  end
end
