FROM elixir:1.8.2

RUN mkdir /app
WORKDIR /app

ENV MIX_ENV=prod
ENV HOME=/app

RUN mix local.hex --force
RUN mix local.rebar --force

ADD mix.lock .
ADD mix.exs .

RUN mix deps.get
RUN mix deps.compile

ADD lib ./lib
ADD config ./config
ADD priv ./priv

ARG SECRET_KEY_BASE

RUN mix compile
RUN mix release --no-confirm-missing

CMD [ "rel/typo_kart/bin/typo_kart", "start" ]