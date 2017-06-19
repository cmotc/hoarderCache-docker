hoarderCache-docker
===================

apt-cacher-ng running in a docker container, optimized for self-hosting updates
to my media center OS/homelab integration project. It uses apt-cacher-ng,
docker, and unattended-upgrades to maintain an up-to-date archive of packages
for a specific configuration on a day-to-day basis, pre-configures several
privacy and security related third-party repositories, and is configured by
feeding it a package list. Packages on the list will be kept up to date
automatically, and other packages will be cached as they are retrieved by any
client of the proxy.

How it works
------------

First, you take a docker container based on Debian sid and install some basic
supporting software:

        FROM debian:sid
        RUN apt-get update
        RUN apt-get install -yq apt-transport-https gpgv-static gnupg2 bash apt-utils curl sysvinit-core

Then, you add some awesome repositories to supplement your well-established
Debian packages. Some have source repositories and some don't, that's OK for
now, just leave out the deb-src entry if there is not a source repository to
use.

        RUN echo deb https://pkg.tox.chat/debian stable sid | tee /etc/apt/sources.list.d/tox.list
        RUN wget -qO - https://pkg.tox.chat/debian/pkg.gpg.key | apt-key add -
        RUN echo "deb http://apt.syncthing.net/ syncthing release" | tee /etc/apt/sources.list.d/syncthing.list
        RUN curl -s https://syncthing.net/release-key.txt | apt-key add -
        RUN echo "deb http://download.opensuse.org/repositories/home:/emby/Debian_Next/ /" | tee /etc/apt/sources.list.d/emby.list
        RUN curl -s https://download.opensuse.org/repositories/home:/emby/Debian_Next/Release.key | apt-key add -
        RUN echo "deb http://repo.lngserv.ru/debian jessie main" | tee /etc/apt/sources.list.d/i2pd.list
        RUN echo "deb-src http://repo.lngserv.ru/debian jessie main" | tee -a /etc/apt/sources.list.d/i2pd.list
        RUN gpg --keyserver keys.gnupg.net --recv-keys 98EBCFE2; \
                gpg -a --export 98EBCFE2 | apt-key add -
        RUN echo "deb http://deb.torproject.org/torproject.org stretch main" | tee /etc/apt/sources.list.d/tor.list
        RUN echo "deb-src http://deb.torproject.org/torproject.org stretch main" | tee -a /etc/apt/sources.list.d/tor.list
        RUN gpg --keyserver keys.gnupg.net --recv-keys A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89; \
                gpg -a --export A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89 | apt-key add -
        RUN echo 'deb http://download.opensuse.org/repositories/home:/stevenpusser/Debian_9.0/ /' | tee /etc/apt/sources.list.d/palemoon.list
        RUN curl -s https://download.opensuse.org/repositories/home:/stevenpusser/Debian_9.0/Release.key | apt-key add -
        RUN echo "deb https://cmotc.github.io/apt-now/deb-pkg rolling main" | tee /etc/apt/sources.list.d/cmotc.github.io.list
        RUN echo "deb-src https://cmotc.github.io/apt-now/deb-pkg rolling main" | tee -a /etc/apt/sources.list.d/cmotc.github.io.list
        RUN curl -s https://cmotc.github.io/apt-now/cmotc.github.io.gpg.key | apt-key add -
        RUN echo "deb-src http://ftp.us.debian.org/debian/ sid main" | tee /etc/apt/sources.list.d/sid-sources.list

Now that you've got your repositories set up, you'll need to update your apt
packages to make your new container aware of them.

        RUN apt-get update

Install some more supporting packages that it wouldn't have made sense to
install earlier, before we had the repositories set up.

        RUN yes N | apt-get install -yq apt-cacher-ng apt-config-auto-update unattended-upgrades apt-now static-page-scripts

Create a user for downloading the source packages, since downloading them as
root would be harmful and unnecesary. While you're at it, create a folder to
use as a working directory when downloading the sources.

        RUN useradd -ms /bin/bash packagecacher
        ADD . /home/packagecacher/sources
        WORKDIR /home/packagecacher/sources

Copy the packages.ist file to the packagecacher folder.

        COPY packages.list /home/packagecacher/

Configure daily, automatic, unattended upgrades

        RUN echo > /etc/apt/apt.conf.d/02periodic; \
                echo APT::Periodic::Enable "1"; > /etc/apt/apt.conf.d/02periodic; \
                echo APT::Periodic::Update-Package-Lists "1"; >> /etc/apt/apt.conf.d/02periodic; \
                echo APT::Periodic::Unattended-Upgrade "1"; >> /etc/apt/apt.conf.d/02periodic; \
                echo APT::Periodic::AutocleanInterval "7"; >> /etc/apt/apt.conf.d/02periodic; \
                echo APT::Periodic::Verbose "0"; >> /etc/apt/apt.conf.d/02periodic

Allow apt-cacher-ng to CONNECT to TLS sites on your behalf

        RUN sed -i 's|# PassThroughPattern: .* # this would allow CONNECT to everything|PassThroughPattern: .* # this would allow CONNECT to everything|' /etc/apt-cacher-ng/acng.conf

And configure apt to point to the local apt-cacher-ng instance.

        RUN echo "Acquire::http { Proxy \"http://127.0.0.1:3142\"; };" | tee /etc/apt/apt.conf.d/02proxy

Now, make sure that the apt-cacher-ng is started and update the package manager.

        RUN service apt-cacher-ng start && \
                export DEBIAN_FRONTEND=noninteractive; \
                apt-get update

And install the packages from packages.list

        RUN service apt-cacher-ng start && \
                export DEBIAN_FRONTEND=noninteractive; \
                apt-get install -yq $(cat /home/packagecacher/packages.list | tr "\n" " ")

Substitute user to the packagecacher user and download all the available source
packages in the packages.list to the sources folder.

        RUN service apt-cacher-ng start && \
        export DEBIAN_FRONTEND=noninteractive; \
        for p in $(cat /home/packagecacher/packages.list | tr "\n" " "); do \
                su packagecacher -c "apt-get source -yq $p"; \
                done

Now you've installed all these packages, and they may have enabled some
services we don't want to run. So disable every one of them:

        RUN for s in $(ls /etc/init.d/); do \
                update-rc.d -f $s disable; \
                done

And re-enable only apt-cacher-ng and unattended-upgrades

        RUN update-rc.d apt-cacher-ng enable
        RUN update-rc.d unattended-upgrades enable

and finally, initialize the container.

        RUN /sbin/init
