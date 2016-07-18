FROM elixir:1.3.1
MAINTAINER NGIBAEV

ADD . /logger
WORKDIR /logger

RUN mix local.hex --force
RUN mix local.rebar --force
RUN mix deps.get

EXPOSE 5556

CMD mix
