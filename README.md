# SupabaseSurfaceDemo

This is a demo of using [Surface](https://github.com/surface-ui/surface) with Supabase.
Mostly it's a playground for myself to get more familiar with Surface and Supabase and maybe end
up with a bunch of reusable components for rapid future development.

To start your Phoenix server:

- Install dependencies with `mix deps.get`
- Install Node.js dependencies with `npm install` inside the `assets` directory
- Create and configure a Supabase project like done [here](https://github.com/supabase/supabase/tree/master/examples/nextjs-ts-user-management#build-from-scratch)
  - make sure the configured app url in the Authentication section is `http://localhost:4000` (or however you will start your Phoenix server)
- Set `SUPABASE_KEY` and `SUPABASE_URL` environment variables
- Start Phoenix endpoint with `mix phx.server`
