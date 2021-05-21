defmodule SupabaseSurfaceDemo.Profile do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:user_id, Ecto.UUID, []}
  schema "profiles" do
    field(:email, :string)
    field(:avatar_url, :string)
    field(:username, :string)
    field(:website, :string)
  end

  def changeset(profile, attrs) do
    profile
    |> cast(attrs, [:user_id, :email, :avatar_url, :username, :website])
    |> validate_required([:user_id, :email])
  end
end
