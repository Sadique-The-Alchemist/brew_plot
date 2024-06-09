defmodule BrewPlot.Brewery.Plot do
  use Ecto.Schema
  import Ecto.Changeset
  alias BrewPlot.Accounts.User
  alias BrewPlot.Brewery.Brew

  @required_fields [:name, :dataset_name, :expression, :user_id]
  @optional_fields [:serialized]
  schema "plots" do
    field :name, :string
    field :dataset_name, :string
    field :expression, :string
    field :serialized, :map
    belongs_to(:user, User)
  end

  def changeset(plot, attrs \\ %{}) do
    plot
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> validate_dataset_name()
  end

  defp validate_dataset_name(changeset) do
    name = get_field(changeset, :dataset_name)

    unless "#{name}.csv" in Brew.valid_files() do
      add_error(changeset, :name, "Not a valid name")
    else
      changeset
    end
  end
end
