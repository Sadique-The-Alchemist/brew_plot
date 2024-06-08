defmodule BrewPlot.Repo do
  use Ecto.Repo,
    otp_app: :brew_plot,
    adapter: Ecto.Adapters.Postgres
end
