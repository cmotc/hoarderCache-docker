FROM debian:sid
VOLUME ["/var/cache/apt-cacher-ng"]
RUN chown -R _apt:root /var/lib/apt/lists/
RUN apt-get update
RUN apt-get install -yq apt-utils
RUN apt-get install -y apt-transport-https gpgv-static gnupg2 bash make curl apt-cacher-ng debian-keyring debian-archive-keyring ubuntu-archive-keyring

RUN echo "http://packages.devuan.org/merged" | tee -a /etc/apt-cacher-ng/backends_devuan
RUN echo "Remap-debrep: file:devuan_mirror /merged ; file:backends_devuan # Debian Archives" | tee -a /etc/apt-cacher-ng/acng.conf

RUN echo "https://repo.lngserv.ru/debian" | tee /etc/apt-cacher-ng/backends_i2pd
RUN gpg --keyserver keys.gnupg.net --recv-keys 98EBCFE2; \
	gpg -a --export 98EBCFE2 | apt-key add -
RUN echo "Remap-i2pd: http://i2p.repo ; file:backends_i2pd" | tee -a /etc/apt-cacher-ng/acng.conf

RUN echo "https://pkg.tox.chat/debian" | tee /etc/apt-cacher-ng/backends_tox
RUN curl -s https://pkg.tox.chat/debian/pkg.gpg.key | apt-key add -
RUN echo "Remap-tox: http://tox.repo ; file:backends_tox" | tee -a /etc/apt-cacher-ng/acng.conf

RUN echo "https://apt.syncthing.net/" | tee /etc/apt-cacher-ng/backends_syncthing
RUN curl -s https://syncthing.net/release-key.txt | apt-key add -
RUN echo "Remap-syncthing: http://syncthing.repo ; file:backends_syncthing" | tee -a /etc/apt-cacher-ng/acng.conf

RUN echo "https://download.opensuse.org/repositories/home:/emby/Debian_Next/" | tee /etc/apt-cacher-ng/backends_emby
RUN curl -s https://download.opensuse.org/repositories/home:/emby/Debian_Next/Release.key | apt-key add -
RUN echo "Remap-emby: http://emby.repo ; file:backends_emby" | tee -a /etc/apt-cacher-ng/acng.conf

RUN echo "https://deb.torproject.org/torproject.org" | tee /etc/apt-cacher-ng/backends_tor
RUN gpg --keyserver keys.gnupg.net --recv-keys A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89; \
	gpg -a --export A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89 | apt-key add -
RUN echo "Remap-tor: http://tor.repo ; file:backends_tor" | tee -a /etc/apt-cacher-ng/acng.conf

RUN echo 'https://download.opensuse.org/repositories/home:/stevenpusser/Debian_9.0/' | tee /etc/apt-cacher-ng/backends_palemoon
RUN curl -s https://download.opensuse.org/repositories/home:/stevenpusser/Debian_9.0/Release.key | apt-key add -
RUN echo "Remap-palemoon: http://palemoon.repo ; file:backends_palemoon" | tee -a /etc/apt-cacher-ng/acng.conf

RUN echo "https://eyedeekay.github.io/apt-now/deb-pkg" | tee /etc/apt-cacher-ng/backends_eyedeekay
RUN curl -s https://eyedeekay.github.io/apt-now/eyedeekay.github.io.gpg.key | apt-key add -
RUN echo "Remap-eyedeekay: http://eyedeekay.repo ; file:backends_eyedeekay" | tee -a /etc/apt-cacher-ng/acng.conf

RUN adduser --home /home/packagecacher --shell /bin/bash packagecacher
RUN chown -R packagecacher:packagecacher /home/packagecacher/
WORKDIR /home/packagecacher

RUN sed -i 's|# PassThroughPattern: .* # this would allow CONNECT to everything|PassThroughPattern: .* # this would allow CONNECT to everything|' /etc/apt-cacher-ng/acng.conf

RUN echo "Acquire::http { Proxy \"http://127.0.0.1:3142\"; };" | tee /etc/apt/apt.conf.d/02proxy
EXPOSE 3142/tcp
ADD . /home/packagecacher/
RUN make launcher
CMD [ "launcher.sh" ]
