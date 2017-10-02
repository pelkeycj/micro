defmodule Micro.Repo.Migrations.CreateRelationships do
  use Ecto.Migration

  def change do
    create table(:relationships) do
      add :follower_id, references(:users, on_delete: :delete_all) # (user who follows)
      add :following_id, references(:users, on_delete: :delete_all ) # (user who is followed)

      timestamps()
    end
    # add indices
    create index :relationships, :follower_id
    create index :relationships, :following_id
    create unique_index(:relationships, [:follower_id, :following_id])


  end
end
