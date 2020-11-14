FROM ubuntu:latest
RUN apt-get update \
      && apt-get -y --no-install-recommends install docker.io iproute2 net-tools python3-pip libcairo2 \
      && pip3 install docker pyroute2 python-igraph cairocffi

COPY add_link.py /
RUN chmod a+rx /add_link.py && mkdir /var/run/netns

ENTRYPOINT ["/usr/bin/python3", "/add_link.py"]
