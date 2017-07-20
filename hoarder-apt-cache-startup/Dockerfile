FROM hoarder-apt-cache-source
WORKDIR /home/packagecacher/
COPY Makefile .
RUN make launcher
EXPOSE 3142/tcp
RUN apt-cacher-ng -c /etc/apt-cacher-ng/ & sleep 3 && \
        apt-get update && \
        apt-get upgrade -y
