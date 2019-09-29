FROM elixir:1.9.1

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

RUN mix compile

RUN mix release

CMD [ "_build/prod/rel/typo_kart/bin/typo_kart", "start" ]