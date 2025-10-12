FROM docker.io/library/debian:12

RUN apt-get update && \
    apt-get install -y sudo socat && \
    rm -rf /var/lib/apt/lists/*

COPY --chown=root:root --chmod=755 startup.sh /

RUN install -dvm700 /opt/startup-early /opt/startup-late && \
    install -dvm755 /opt/xfwd

ENV LC_ALL=C.UTF-8
RUN echo '#!/bin/bash\n\nexport LC_ALL=C.UTF-8' \
    > /etc/profile.d/set-c-utf8-locale.sh

ENV DISPLAY=:0 XAUTHORITY=/opt/xfwd/container.xauth

ENTRYPOINT ["/startup.sh"]
