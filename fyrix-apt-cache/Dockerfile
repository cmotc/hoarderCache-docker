FROM base-apt-cache
RUN yes N | apt-get install -yq apt-cacher-ng apt-config-auto-update unattended-upgrades apt-now static-page-scripts
RUN useradd -ms /bin/bash packagecacher
ADD . /home/packagecacher/sources
RUN chown -R packagecacher:packagecacher /home/packagecacher/sources
WORKDIR /home/packagecacher
COPY ../packages.list /home/packagecacher/
RUN echo > /etc/apt/apt.conf.d/02periodic; \
        echo APT::Periodic::Enable "1"; > /etc/apt/apt.conf.d/02periodic; \
        echo APT::Periodic::Update-Package-Lists "1"; >> /etc/apt/apt.conf.d/02periodic; \
        echo APT::Periodic::Unattended-Upgrade "1"; >> /etc/apt/apt.conf.d/02periodic; \
        echo APT::Periodic::AutocleanInterval "7"; >> /etc/apt/apt.conf.d/02periodic; \
        echo APT::Periodic::Verbose "0"; >> /etc/apt/apt.conf.d/02periodic
RUN echo "Unattended-Upgrade::Origins-Pattern {" > /etc/apt/apt.conf.d/50unattended-upgrades; \
        echo "\*" >> /etc/apt/apt.conf.d/50unattended-upgrades; \
        echo "};" >> /etc/apt/apt.conf.d/50unattended-upgrades
RUN sed -i 's|# PassThroughPattern: .* # this would allow CONNECT to everything|PassThroughPattern: .* # this would allow CONNECT to everything|' /etc/apt-cacher-ng/acng.conf
RUN echo "Acquire::http { Proxy \"http://127.0.0.1:3142\"; };" | tee /etc/apt/apt.conf.d/02proxy
