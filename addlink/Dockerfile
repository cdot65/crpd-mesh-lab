FROM ubuntu:latest
RUN apt-get update \
      && apt-get -y --no-install-recommends install docker.io iproute2 net-tools

COPY add_link.sh /
RUN chmod a+rx /add_link.sh

ENTRYPOINT ["/bin/bash", "/add_link.sh"]
