FROM hoarder-apt-cache
WORKDIR /home/packagecacher/sources
RUN service apt-cacher-ng start && \
        export DEBIAN_FRONTEND=noninteractive; \
        for p in $(cat /home/packagecacher/packages.list | tr "\n" " "); do \
                su packagecacher -c "apt-get source -yq $p"; \
                done
RUN for s in $(ls /etc/init.d/); do \
        systemctl disable $s; \
        done
RUN systemctl enable apt-cacher-ng
RUN systemctl enable unattended-upgrades
RUN /usr/sbin/launcher.sh
