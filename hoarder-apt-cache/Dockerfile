FROM fyrix-apt-cache
RUN service apt-cacher-ng start && \
        export DEBIAN_FRONTEND=noninteractive; \
        apt-get update
RUN service apt-cacher-ng start && \
        export DEBIAN_FRONTEND=noninteractive; \
        apt-get install -yq $(cat /home/packagecacher/packages.list | tr "\n" " ")
