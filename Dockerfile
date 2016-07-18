FROM elixir:1.3.1
MAINTAINER NGIBAEV

ADD . /logger
WORKDIR /logger

ENV LOGS_DIR /var/log/logger_service

RUN ./build.sh
RUN mix local.hex --force
RUN mix local.rebar --force
RUN mix deps.get
RUN mix deps.compile

EXPOSE 5556

VOLUME [$LOGS_DIR]

CMD mix
