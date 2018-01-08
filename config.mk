
export ltip=$(shell ip route | grep -v link | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '.0.1' | grep -v '.0.0')

ip:
	@echo "$(ltip)"

define detect_proxy_script
#!/bin/bash
# detect-http-proxy - Returns a HTTP proxy which is available for use

# Author: Lekensteyn <lekensteyn@gmail.com>

# Supported since APT 0.7.25.3ubuntu1 (Lucid) and 0.7.26~exp1 (Debian Squeeze)
# Unsupported: Ubuntu Karmic and before, Debian Lenny and before

# Put this file in /etc/apt/detect-http-proxy and create and add the below
# configuration in /etc/apt/apt.conf.d/30detectproxy
#    Acquire::http::ProxyAutoDetect "/etc/apt/detect-http-proxy";

# APT calls this script for each host that should be connected to. Therefore
# you may see the proxy messages multiple times (LP 814130). If you find this
# annoying and wish to disable these messages, set show_proxy_messages to 0
show_proxy_messages=0

# on or more proxies can be specified. Note that each will introduce a routing
# delay and therefore its recommended to put the proxy which is most likely to
# be available on the top. If no proxy is available, a direct connection will
# be used
try_proxies=(
$(ltip):3142/
127.0.0.1:3142/
packages.devuan.org:80/
$(ltip):3143/
127.0.01:3143/
)

print_msg() {
    # \x0d clears the line so [Working] is hidden
    [ "$$show_proxy_messages" = 1 ] && printf '\x0d%s\n' "$$1" >&2
}

for proxy in "$${try_proxies[@]}"; do
    # if the host machine / proxy is reachable...
    if nc -z $${proxy/:/ }; then
		if [ $${proxy} == packages.devuan.org:80 ]; then
			proxy=DIRECT
			echo "$$proxy"
			exit
		else
			proxy=http://$$proxy
			print_msg "Proxy that will be used: $$proxy"
			echo "$$proxy"
			exit
		fi
    fi
done
print_msg "No proxy will be used"

# Workaround for Launchpad bug 654393 so it works with Debian Squeeze (<0.8.11)
echo DIRECT
endef

export detect_proxy_script

proxyscript:
	@echo "$$detect_proxy_script" | tee hoardercache-detect-proxy

proxyconf:
	@echo -n "Acquire::http::Proxy-Auto-Detect \"/usr/local/bin/hoardercache-detect-proxy\";" | tee auto-apt-proxy.conf

install-proxyscript: proxyscript
	install hoardercache-detect-proxy /usr/local/bin/

install-proxyconf: proxyscript proxyconf install-proxyscript
	install auto-apt-proxy.conf /etc/apt/apt.conf.d/auto-apt-proxy.conf

export username ?= "acng"
export password ?= "$(shell apg -n 1 -E '($)\' )"

export working_directory ?= $(shell pwd)
export cache_directory ?= $(working_directory)/cache

export proxy_host = $(shell ./hoardercache-detect-proxy | sed 's|:3142/||g' | sed 's|:3143/||g' | sed 's|http://||g')
export proxy_host ?= 192.168.1.98
export proxy_port = 3142/

export proxy_addr = http://$(proxy_host):$(proxy_port)

proxycheck:
	@echo "$(proxy_host)"
	@echo "$(proxy_port)"
	@echo "$(proxy_addr)"

.get-addons:
	git clone https://github.com/eyedeekay/hoardercache-syncthing.git 2>/dev/null; true
	@echo "" >> include.mk
	@echo "include hoardercache-syncthing/include.mk" >> include.mk
	git clone https://github.com/eyedeekay/hoardercache-overlaynets.git 2>/dev/null; true
	@echo "" >> include.mk
	@echo "include hoardercache-overlaynets/include.mk" >> include.mk
	touch .get-addons

addon-build: addon-syncthing-build addon-overlaynets-build

addon-restart: addon-syncthing-restart

addon-update: addon-syncthing-update

addon-clobber: addon-syncthing-clobber

include include.mk
