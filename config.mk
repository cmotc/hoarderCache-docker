
export username ?= "acng"
export password ?= "$(shell apg -n 1 -E '($)' )"

export working_directory ?= $(shell pwd)
export cache_directory ?= $(working_directory)/cache

export proxy_host ?= 192.168.1.98
export proxy_port = 3142/

export proxy_addr = http://$(proxy_host):$(proxy_port)

.get-addons:
	git clone https://github.com/eyedeekay/hoardercache-syncthing.git 2>/dev/null; true
	@echo "" >> include.mk
	@echo "include hoardercache-syncthing/include.mk" >> include.mk
	touch .get-addons

addon-build: addon-syncthing-build

addon-restart: addon-syncthing-restart

addon-update: addon-syncthing-update

addon-clobber: addon-syncthing-clobber

include include.mk
