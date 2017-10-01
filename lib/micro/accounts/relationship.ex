defmodule Micro.Accounts.Relationship do
  use Ecto.Schema

  alias Micro.Accounts.User

  schema "relationships" do
    belongs_to :follower, User  # user who follows
    belongs_to :following, User # user who is followed
  end
end
