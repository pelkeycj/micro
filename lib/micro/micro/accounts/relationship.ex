defmodule Micro.Micro.Accounts.Relationship do
  use Ecto.Schema
  import Ecto.Changeset
  alias Micro.Micro.Accounts.Relationship


  schema "relationships" do

    timestamps()
  end

  @doc false
  def changeset(%Relationship{} = relationship, attrs) do
    relationship
    |> cast(attrs, [])
    |> validate_required([])
  end
end
