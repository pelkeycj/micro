defmodule Micro.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :name, :string
      add :handle, :string
      add :bio, :text

      timestamps()
    end

    create unique_index(:users, [:handle])
  end
end
