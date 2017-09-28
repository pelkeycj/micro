defmodule Micro.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias Micro.Accounts.User


  schema "users" do
    field :bio, :string
    field :handle, :string
    field :name, :string

    timestamps()
  end

  @doc false
  def changeset(%User{} = user, attrs) do
    user
    |> cast(attrs, [:name, :handle, :bio])
    |> validate_required([:name, :handle, :bio])
    |> unique_constraint(:handle)
  end
end
