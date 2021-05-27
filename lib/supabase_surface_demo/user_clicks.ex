defmodule SupabaseSurfaceDemo.UserClicks do
  alias SupabaseSurfaceDemo.UserClick
  alias SupabaseSurfaceDemo.Repo

  import Ecto.Query

  def get_num_clicks() do
    Repo.aggregate(UserClick, :max, :id) || 0
  end

  def get_num_clicks_user(user_id) do
    filters = [user_id: user_id]
    query = from(c in UserClick, where: ^filters)
    Repo.aggregate(query, :count)
  end

  def create_click(user_id) do
    click = UserClick.changeset(%{user_id: user_id})
    Repo.insert!(click)
  end
end
