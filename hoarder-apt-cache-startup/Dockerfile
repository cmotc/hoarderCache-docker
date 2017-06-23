FROM hoarder-apt-cache-source
WORKDIR /home/packagecacher/
COPY Makefile .
RUN make launcher
RUN ./launcher.sh
