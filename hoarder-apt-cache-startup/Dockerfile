FROM hoarder-apt-cache-source
WORKDIR /home/packagecacher/
COPY Makefile .
RUN make launcher
RUN for s in $(ls /etc/init.d/); do \
        systemctl disable $s; \
        done
RUN systemctl enable apt-cacher-ng
RUN systemctl enable cron
RUN systemctl enable unattended-upgrades
RUN /bin/launcher.sh
