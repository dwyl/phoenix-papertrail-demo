defmodule SpikePapertrail.Repo do
  use Ecto.Repo,
    otp_app: :spike_papertrail,
    adapter: Ecto.Adapters.Postgres
end
