FROM hoarder-apt-cache-source
WORKDIR /home/packagecacher/
RUN for s in $(ls /etc/init.d/); do \
        systemctl disable $s; \
        done
RUN systemctl enable apt-cacher-ng
RUN systemctl enable cron
RUN systemctl enable unattended-upgrades
COPY Makefile .
RUN make launcher
RUN apt-get update && apt-get updgrade -y
