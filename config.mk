
export username ?= "acng"
export password ?= "$(shell apg -n 1)"

export working_directory ?= $(shell pwd)
export cache_directory ?= "$(working_directory)/cache"


.get-addons:
	git clone git@github.com:eyedeekay/hoardercache-syncthing.git 2>/dev/null; true
	@echo "" >> config.mk
	@echo "include hoardercache-syncthing/include.mk" >> config.mk
	touch .get-addons


