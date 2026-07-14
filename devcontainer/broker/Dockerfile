FROM ubuntu:24.04

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    dbus \
    libnotify-bin \
    pulseaudio-utils \
    socat \
    util-linux \
    && rm -rf /var/lib/apt/lists/*

COPY handle-notify.sh /usr/local/bin/handle-notify.sh
RUN chmod 755 /usr/local/bin/handle-notify.sh

RUN mkdir -p /run/broker && chmod 777 /run/broker

CMD ["socat", "UNIX-LISTEN:/run/broker/notify.sock,fork,unlink-early,mode=777", "EXEC:/usr/local/bin/handle-notify.sh"]
