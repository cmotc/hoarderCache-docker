FROM debian:sid
VOLUME ["/var/cache/apt-cacher-ng"]
RUN chmod 777 /var/cache/apt-cacher-ng
RUN chown -R _apt:root /var/lib/apt/lists/
RUN apt-get update
RUN apt-get install -yq apt-utils
RUN apt-get install -yq apt-transport-https gpgv-static gnupg2 bash make curl apt-cacher-ng
RUN echo "deb-src http://repo.lngserv.ru/debian jessie main" | tee -a /etc/apt/sources.list.d/i2pd.list
RUN gpg --keyserver keys.gnupg.net --recv-keys 98EBCFE2; \
	gpg -a --export 98EBCFE2 | apt-key add -
RUN echo deb https://pkg.tox.chat/debian stable sid | tee /etc/apt/sources.list.d/tox.list
RUN wget -qO - https://pkg.tox.chat/debian/pkg.gpg.key | apt-key add -
RUN echo "deb http://apt.syncthing.net/ syncthing release" | tee /etc/apt/sources.list.d/syncthing.list
RUN curl -s https://syncthing.net/release-key.txt | apt-key add -
RUN echo "deb http://download.opensuse.org/repositories/home:/emby/Debian_Next/ /" | tee /etc/apt/sources.list.d/emby.list
RUN curl -s https://download.opensuse.org/repositories/home:/emby/Debian_Next/Release.key | apt-key add -
RUN echo "deb http://repo.lngserv.ru/debian jessie main" | tee /etc/apt/sources.list.d/i2pd.list
RUN echo "deb http://deb.torproject.org/torproject.org stretch main" | tee /etc/apt/sources.list.d/tor.list
RUN echo "deb-src http://deb.torproject.org/torproject.org stretch main" | tee -a /etc/apt/sources.list.d/tor.list
RUN gpg --keyserver keys.gnupg.net --recv-keys A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89; \
	gpg -a --export A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89 | apt-key add -
RUN echo 'deb http://download.opensuse.org/repositories/home:/stevenpusser/Debian_9.0/ /' | tee /etc/apt/sources.list.d/palemoon.list
RUN curl -s https://download.opensuse.org/repositories/home:/stevenpusser/Debian_9.0/Release.key | apt-key add -
RUN echo "deb https://eyedeekay.github.io/apt-now/deb-pkg rolling main" | tee /etc/apt/sources.list.d/eyedeekay.github.io.list
RUN echo "deb-src https://eyedeekay.github.io/apt-now/deb-pkg rolling main" | tee -a /etc/apt/sources.list.d/eyedeekay.github.io.list
RUN curl -s https://eyedeekay.github.io/apt-now/eyedeekay.github.io.gpg.key | apt-key add -
RUN echo "deb-src http://ftp.us.debian.org/debian/ sid main" | tee /etc/apt/sources.list.d/sid-sources.list
RUN apt-get update
RUN apt-get install -y apt-cacher-ng
RUN adduser --home /home/packagecacher --shell /bin/bash packagecacher
RUN chown -R packagecacher:packagecacher /home/packagecacher/
WORKDIR /home/packagecacher
RUN sed -i 's|# PassThroughPattern: .* # this would allow CONNECT to everything|PassThroughPattern: .* # this would allow CONNECT to everything|' /etc/apt-cacher-ng/acng.conf
RUN echo "Acquire::http { Proxy \"http://127.0.0.1:3142\"; };" | tee /etc/apt/apt.conf.d/02proxy
EXPOSE 3142/tcp
ADD . /home/packagecacher/
RUN cat /etc/init.d/apt-cacher-ng
RUN make launcher
CMD [ "/bin/launcher.sh" ]
