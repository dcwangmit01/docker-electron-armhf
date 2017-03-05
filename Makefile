SHELL := /bin/bash

SOURCE := github.com/dcwangmit01/docker-electron-armhf
PACKAGE := registry.davidwang.com/paxarm/docker-electron-armhf
VERSION:= dev

CACHE_DIR=.cache
TMP_DIR=.tmp

ELECTRON_ARCH=armv7l
ELECTRON_VERSION=1.4.15
ELECTRON_PACKAGE=electron-v$(ELECTRON_VERSION)-linux-$(ELECTRON_ARCH).zip
ELECTRON_URL=https://github.com/electron/electron/releases/download/v$(ELECTRON_VERSION)/$(ELECTRON_PACKAGE)
FFMPEG_PACKAGE=ffmpeg-v$(ELECTRON_VERSION)-linux-$(ELECTRON_ARCH).zip
FFMPEG_URL=https://github.com/electron/electron/releases/download/v$(ELECTRON_VERSION)/$(FFMPEG_PACKAGE)
ELECTRON_DIR=$(basename $(ELECTRON_PACKAGE))
ELECTRON_TGZ=$(basename $(ELECTRON_PACKAGE)).tar.gz


$(CACHE_DIR)/$(ELECTRON_TGZ):
	: # Download the electron pkg, and the non-proprietary ffmeg pkg
	mkdir -p $(CACHE_DIR)
	if [ ! -f $(CACHE_DIR)/$(ELECTRON_PACKAGE) ]; then \
	  curl -fsSL $(ELECTRON_URL) > $(CACHE_DIR)/$(ELECTRON_PACKAGE); \
	fi
	if [ ! -f $(CACHE_DIR)/$(FFMPEG_PACKAGE) ]; then \
	  curl -fsSL $(FFMPEG_URL) > $(CACHE_DIR)/$(FFMPEG_PACKAGE); \
	fi

	: # convert zip files into a single gzip file
	: #   that dockerbuild can copy directly into archive
	rm -rf $(CACHE_DIR)/$(ELECTRON_DIR)
	mkdir -p $(CACHE_DIR)/$(ELECTRON_DIR)
	unzip -o -d $(CACHE_DIR)/$(ELECTRON_DIR) $(CACHE_DIR)/$(ELECTRON_PACKAGE)
	unzip -o -d $(CACHE_DIR)/$(ELECTRON_DIR) $(CACHE_DIR)/$(FFMPEG_PACKAGE)
	pushd $(CACHE_DIR)/$(ELECTRON_DIR) && tar czf ../$(ELECTRON_TGZ) .
	rm -rf $(CACHE_DIR)/$(ELECTRON_DIR)

$(CACHE_DIR)/qemu-arm-static:
	cp /usr/bin/qemu-arm-static $(CACHE_DIR)

$(CACHE_DIR)/00aptproxy:
	if [ -f /etc/apt/apt.conf.d/00aptproxy ]; then \
	  cp /etc/apt/apt.conf.d/00aptproxy $(CACHE_DIR)/00aptproxy; \
	else \
	  touch $(CACHE_DIR)/00aptproxy; \
	fi

deps:
	npm install

docker: $(CACHE_DIR)/$(ELECTRON_TGZ) \
	$(CACHE_DIR)/qemu-arm-static \
	$(CACHE_DIR)/00aptproxy # deps
	docker build \
		--build-arg ELECTRON_TGZ=$(CACHE_DIR)/$(ELECTRON_TGZ) \
		--tag $(PACKAGE):$(VERSION) .

docker-push:
	docker push $(PACKAGE):$(VERSION)

docker-run:
	docker run --rm -it $(PACKAGE):$(VERSION) bash
	: #docker run -it --rm -v /usr/bin/qemu-arm-static:/usr/bin/qemu-arm-static test bash

clean:
	rm -rf $(CACHE_DIR)
	rm -rf $(TMP_DIR)

mrclean: clean
	rm -rf ./node_modules
