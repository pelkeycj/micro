defmodule Micro.Accounts.Relationship do
  use Ecto.Schema
  import Ecto.Changeset

  alias Micro.Accounts.User

  schema "relationships" do
    belongs_to :follower, User  # user who follows
    belongs_to :following, User # user who is followed
    timestamps()
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:follower_id, :following_id])
    |> validate_required([:follower_id, :following_id])

  end

end
