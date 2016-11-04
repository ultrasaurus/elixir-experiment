FROM elixir:1.3.4

ENV DEBIAN_FRONTEND=noninteractive

ARG APP_NAME
ARG APP_VERSION
ENV PORT 4000
ENV MIX_ENV prod

RUN mix local.hex --force && \
    mix local.rebar --force

# Volume local directory
COPY . /build

WORKDIR /build
RUN mix do deps.get, deps.compile && \
    mix do compile, release    

RUN mkdir -p /$APP_NAME && \
    mkdir -p /$APP_NAME/releases/$APP_VERSION

RUN mv rel/$APP_NAME/bin /$APP_NAME/bin && \
    mv rel/$APP_NAME/lib /$APP_NAME/lib && \
    mv rel/$APP_NAME/releases/start_erl.data /$APP_NAME/releases/start_erl.data &&\
    mv rel/$APP_NAME/releases/$APP_VERSION /$APP_NAME/releases

RUN ln -s /$APP_NAME/bin/$APP_NAME bin/start

EXPOSE $PORT

WORKDIR /$APP_NAME

CMD trap exit TERM; bin/start foreground & wait