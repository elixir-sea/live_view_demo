#!/usr/bin/env bash

# Get tools
asdf install
asdf reshim

# Setup Elixir
mix deps.get

# Setup JS
cd assets && npm install && cd --

# Setup PG
createuser postgres --superuser --createrole
pg_ctl start
mix ecto.setup
