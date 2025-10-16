defmodule ElxirComposition.Repo do
  use Ecto.Repo,
    otp_app: :elxir_composition,
    adapter: Ecto.Adapters.Postgres
end
