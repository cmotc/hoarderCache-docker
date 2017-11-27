
export username ?= "acng"
export password ?= "$(shell apg -n 1)"

export working_directory ?= $(shell pwd)
export cache_directory ?= $(working_directory)/cache

export proxy_host ?= 172.17.0.2
export proxy_port = 3142/

export proxy_addr = http://$(proxy_host):$(proxy_port)

.get-addons:
	git clone git@github.com:eyedeekay/hoardercache-syncthing.git 2>/dev/null; true
	@echo "" >> config.mk
	@echo "include hoardercache-syncthing/include.mk" >> config.mk
	touch .get-addons


include hoardercache-syncthing/include.mk

addon-build: addon-syncthing-build

addon-restart: addon-syncthing-restart

addon-update: addon-syncthing-update

addon-clobber: addon-syncthing-clobber
