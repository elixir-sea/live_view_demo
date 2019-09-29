FROM elixir:1.9.1

RUN mkdir /app
WORKDIR /app

ENV MIX_ENV=prod
ENV HOME=/app

RUN mix local.hex --force
RUN mix local.rebar --force
RUN curl -sL https://deb.nodesource.com/setup_12.x | bash -
RUN apt-get install -y nodejs

ADD mix.lock .
ADD mix.exs .

RUN mix deps.get
RUN mix deps.compile

ADD lib ./lib
ADD config ./config
ADD priv ./priv
ADD assets ./assets
RUN cd assets && npm install && npm run deploy
RUN mix compile
RUN mix release

CMD [ "_build/prod/rel/typo_kart/bin/typo_kart", "start" ]