FROM elixir:1.3.4

# RUN apk --update add \
#     erlang erlang-sasl erlang-crypto erlang-syntax-tools && \
#     rm -rf /var/cache/apk/*

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

WORKDIR /build
RUN mkdir -p /$APP_NAME && \
    mkdir -p /$APP_NAME/releases/$APP_VERSION

RUN mv rel/$APP_NAME/bin /$APP_NAME/bin && \
    mv rel/$APP_NAME/lib /$APP_NAME/lib && \
    mv rel/$APP_NAME/releases/start_erl.data /$APP_NAME/releases/start_erl.data &&\
    mv rel/$APP_NAME/releases/$APP_VERSION /$APP_NAME/releases
# ADD rel/$APP_NAME/bin /$APP_NAME/bin
# ADD rel/$APP_NAME/lib /$APP_NAME/lib
# ADD rel/$APP_NAME/releases/start_erl.data                 /$APP_NAME/releases/start_erl.data
# ADD rel/$APP_NAME/releases/$APP_VERSION/$APP_NAME.sh      /$APP_NAME/releases/$APP_VERSION/$APP_NAME.sh
# ADD rel/$APP_NAME/releases/$APP_VERSION/$APP_NAME.boot    /$APP_NAME/releases/$APP_VERSION/$APP_NAME.boot
# ADD rel/$APP_NAME/releases/$APP_VERSION/$APP_NAME.rel     /$APP_NAME/releases/$APP_VERSION/$APP_NAME.rel
# ADD rel/$APP_NAME/releases/$APP_VERSION/$APP_NAME.script  /$APP_NAME/releases/$APP_VERSION/$APP_NAME.script
# ADD rel/$APP_NAME/releases/$APP_VERSION/start.boot        /$APP_NAME/releases/$APP_VERSION/start.boot
# ADD rel/$APP_NAME/releases/$APP_VERSION/sys.config        /$APP_NAME/releases/$APP_VERSION/sys.config
# ADD rel/$APP_NAME/releases/$APP_VERSION/vm.args           /$APP_NAME/releases/$APP_VERSION/vm.args

EXPOSE $PORT

WORKDIR /$APP_NAME
RUN ln -s /$APP_NAME/bin/$APP_NAME bin/start

RUN ls -l /$APP_NAME/bin && \
    ls -l /$APP_NAME/releases/$APP_VERSION

CMD trap exit TERM; bin/start foreground & wait