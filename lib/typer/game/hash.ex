defmodule Typer.Game.Hash do
  use Ecto.Schema
  import Ecto.Changeset
  alias Typer.Accounts.User
  schema "hashes" do
    field :app_title, :string
    field :hash, :string
    belongs_to :user, User
    timestamps(type: :utc_datetime)
  end


#   def changeset(hash, attrs) do
#     hash
#     |> cast(attrs, [:app_title, :hash])
#     |> validate_required([:app_title, :hash])

#   end
# end
@doc false
def changeset(hash, attrs) do
  hash
  |> cast(attrs, [:app_title, :hash, :user_id]) # Ensure :user_id is included if you're setting it directly
  |> validate_required([:app_title, :hash])
  |> foreign_key_constraint(:user_id) # Helpful for handling deletion or nullification behavior
end
end
