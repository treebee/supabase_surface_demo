defmodule SupabaseSurfaceDemoWeb.ImageController do
  use SupabaseSurfaceDemoWeb, :controller

  def public(conn, %{"user_id" => user_id, "filename" => filename}) do
    blob = "public/" <> user_id <> "/" <> filename

    {:ok, data} =
      conn
      |> get_session(:access_token)
      |> Supabase.storage()
      |> Supabase.Storage.from("avatars")
      |> Supabase.Storage.download(blob)

    conn
    |> put_resp_content_type(MIME.from_path(filename))
    |> put_resp_header("cache-control", "public, max-age=15552000")
    |> send_resp(200, data)
  end
end
