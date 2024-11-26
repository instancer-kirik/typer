import Config

# Note we also include the path to a cache manifest
# containing the digested version of static files. This
# manifest is generated by the `mix assets.deploy` task,
# which you should run after static files are built and
# before starting your production server.
# config :typer, TyperWeb.Endpoint, cache_static_manifest: "priv/static/cache_manifest.json"
config :typer, TyperWeb.Endpoint,
  url: [host: "instance.select", port: 443, scheme: "https"],
  http: [
    port: 4000
  ],
  https: [
    port: 4001,
    cipher_suite: :strong,
    certfile: "priv/cert/selfsigned.pem",
    keyfile: "priv/cert/selfsigned_key.pem"
  ],
  check_origin: ["https://instance.select"],
  cache_static_manifest: "priv/static/cache_manifest.json",
  server: true,
  render_errors: [
    formats: [html: TyperWeb.ErrorHTML, json: TyperWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: Typer.PubSub,
  live_view: [signing_salt: "_CLvmXLvmXpMV1yHv+J+"]

# Configures Swoosh API Client
config :swoosh, api_client: Swoosh.ApiClient.Finch, finch_name: Typer.Finch

# Disable Swoosh Local Memory Storage
config :swoosh, local: false

# Do not print debug messages in production
config :logger, level: :info

# Runtime production configuration, including reading
# of environment variables, is done on config/runtime.exs.
import Config
