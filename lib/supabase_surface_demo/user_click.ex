defmodule SupabaseSurfaceDemo.UserClick do
  use Ecto.Schema
  import Ecto.Changeset

  schema "user_clicks" do
    field(:user_id, Ecto.UUID)
  end

  def changeset(attrs) do
    %__MODULE__{}
    |> cast(attrs, [:user_id])
    |> validate_required([:user_id])
  end
end
