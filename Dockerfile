FROM elixir:1.3.1
MAINTAINER NGIBAEV

ADD . /logger
WORKDIR /logger

ENV LOGS_DIR /var/log/logger_service

RUN git clone https://github.com/zeromq/libzmq
RUN cd libzmq
RUN ./autogen.sh && ./configure && make -j 4
RUN make check && make install
RUN ../

RUN mix local.hex --force
RUN mix local.rebar --force
RUN mix deps.get

EXPOSE 5556

VOLUME [$LOGS_DIR]

CMD mix
