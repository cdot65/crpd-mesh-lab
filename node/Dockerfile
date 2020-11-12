FROM crpd:20.3R1.8
RUN apt-get update \
  && apt-get -y --no-install-recommends install bwm-ng avahi-autoipd gettext-base \
  && rm -rf /var/lib/apt/lists/*

COPY runit-init.sh /sbin/
RUN chmod +x /sbin/runit-init.sh

WORKDIR /root
# SIGRTMIN+3  ## using this leads to termination issue on SP//
STOPSIGNAL 35
