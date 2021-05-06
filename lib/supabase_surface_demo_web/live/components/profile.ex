defmodule SupabaseSurfaceDemoWeb.Components.Profile do
  use Surface.LiveComponent

  alias Surface.Components.Form
  alias Surface.Components.Form.{Field, TextInput, Submit}

  @doc "The profile data to display"
  prop(profile, :map, required: true)

  @doc "CSS classes to pass to the outer HTML element"
  prop(class, :css_class, required: true)

  @impl true
  def render(assigns) do
    ~H"""
    <div class={{ "grid grid-cols-1 md:grid-cols-2 gap-16 text-white px-8 py-6 bg-gray-700 border border-gray-600 border-opacity-60 rounded-md", @class }}>
      <div>
      <h2 class="text-2xl font-bold text-green-500">Hi {{ Map.get(@profile, "username") }}</h2>
      <Form for={{ :profile }} change="change" submit="submit"
        class="py-4">
        <Field name="email" class="font-semibold text-md mb-4">
          <div class="flex items-center mt-4">
            <TextInput
              value="{{ @profile["email"] }}"
              opts={{ readonly: true }}
              class="text-xs px-4 py-2 text-gray-400 bg-transparent border border-gray-400 rounded-md w-full" />
          </div>
        </Field>
        <Field name="username" class="font-semibold text-md mb-4">
          <div class="flex items-center mt-4">
            <TextInput
              value="{{ @profile["username"] }}" class="placeholder-gray-400 text-xs px-4 py-2 bg-transparent border border-gray-400 rounded-md w-full" />
          </div>
        </Field>
        <Field name="website" class="font-semibold text-md mb-4">
          <div class="flex items-center mt-4">
            <TextInput
              value="{{ @profile["website"] }}" opts={{ placeholder: "Your website" }} class="placeholder-gray-400 text-xs px-4 py-2 bg-transparent border border-gray-400 rounded-md w-full" />
          </div>
        </Field>

        <Submit class="bg-brand-800 hover:bg-brand-900 w-full py-2 rounded-md font-semibold text-white uppercase">update</Submit>
      </Form>
      <Form for={{ :logout }} method="post" action="/logout">
        <Submit class="border-2 border-brand-800 hover:bg-gray-900 w-full py-2 rounded-md font-semibold text-white">Logout</Submit>
      </Form>
      </div>
      <div>
      </div>
    </div>
    """
  end
end
