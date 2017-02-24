# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :daychat,
  ecto_repos: [Daychat.Repo]

# Configures the endpoint
config :daychat, Daychat.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "gi54i5B/YVRYkcQPEEp4tyFkLP56WnhpkpWHCmuddk/XUG3AjJGO1aPWb36gmsF0",
  render_errors: [view: Daychat.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Daychat.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]


config :sentry,
  dsn: "https://#{System.get_env("SENTRY_PUBLIC")}:#{System.get_env("SENTRY_SECRET")}@sentry.io/#{System.get_env("SENTRY_ID")}",
  environment_name: :prod,
  tags: %{
    env: "production"
  },
  included_environments: [:prod]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
