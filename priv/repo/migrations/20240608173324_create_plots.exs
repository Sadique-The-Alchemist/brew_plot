defmodule BrewPlot.Repo.Migrations.CreatePlots do
  use Ecto.Migration

  def change do
    create table(:plots) do
      add :name, :string
      add :dataset_name, :string
      add :expression, :string
      add :serialized, :map
      add :user_id, references(:users, on_delete: :nothing)
      timestamps()
    end
  end
end
