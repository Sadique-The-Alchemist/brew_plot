defmodule BrewPlot.Repo.Migrations.AddSharedPlot do
  use Ecto.Migration

  def change do
    create table(:shared_plots) do
      add :plot_id, references(:plots, on_delete: :nothing)
      add :user_id, references(:users, on_delete: :nothing)
      timestamps()
    end

    create unique_index(:shared_plots, [:plot_id, :user_id], name: :plot_user_unique_index)
  end
end
