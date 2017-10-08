defmodule Micro.Repo.Migrations.CreateLikes do
  use Ecto.Migration

  def change do
    create table(:likes) do
      add :user_id, references(:users, on_delete: :delete_all)
      add :post_id, references(:posts, on_delete: :delete_all)

      timestamps()
    end

    create index(:likes, [:user_id])
    create index(:likes, [:post_id])

  end
end
