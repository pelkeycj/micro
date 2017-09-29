defmodule Micro.Repo.Migrations.AddUserIdToPosts do
  use Ecto.Migration

  def change do
    alter table(:posts) do
      add :user_id, references(:user) # add field to :posts table. each post needs a user id
    end

    create index(:posts, [:user_id])
  end
end
