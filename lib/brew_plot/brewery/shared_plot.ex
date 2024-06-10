defmodule BrewPlot.Brewery.SharedPlot do
  import Ecto.Changeset
  use Ecto.Schema
  alias BrewPlot.Accounts.User
  alias BrewPlot.Brewery.Plot
  @required_attrs [:user_id, :plot_id]
  schema "shared_plots" do
    belongs_to(:user, User)
    belongs_to(:plot, Plot)
    field :email, :string, virtual: true
    timestamps()
  end

  def changeset(shared_plot, attrs) do
    shared_plot
    |> cast(attrs, @required_attrs)
    |> validate_required(@required_attrs)
  end
end
