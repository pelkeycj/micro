defmodule Micro.Repo.Migrations.AddIdToLikes do
  use Ecto.Migration

  def change do
    alter table(:likes) do
      add :user_id, references(:users, on_delete: :delete_all)
      add :post_id, references(:posts, on_delete: :delete_all)
    end

    create index(:likes, [:user_id])
    create index(:likes, [:post_id])
    create unique_index(:likes, [:post_id, :user_id])

  end
end
