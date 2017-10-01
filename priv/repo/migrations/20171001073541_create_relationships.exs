defmodule Micro.Repo.Migrations.CreateRelationships do
  use Ecto.Migration

  def change do
    create table(:relationships) do
      add :follower_id, references(:users) # (user who follows)
      add :followed_id, references(:users) # (user who is followed)

      timestamps()
    end
    # add indices
    create index :relationships, :follower_id
    create index :relationships, :followed_id
    create unique_index(:relationships, [:follower_id, :followed_id])


  end
end
