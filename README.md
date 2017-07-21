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
