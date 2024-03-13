PWD=$(shell pwd)
TARGET=x86_64-native-linuxapp-gcc
DPDK_DIR=$(PWD)/dpdk-21.11
DPDK_ARCH=x86_64
DPDK_INSTALL_DIR=$(DPDK_DIR)/$(DPDK_ARCH)_install_dir
DPDK_BUILD_DIR=$(DPDK_ARCH)_build
#export PKG_CONFIG_PATH=$(DPDK_DIR)/install_dir/lib/pkgconfig

VPP_DIR=$(PWD)/vpp

all: dpdk vpp-debug

##git clone http://dpdk.org/git/dpdk
define dpdk_21_11
	echo "[note] build dpdk 21.11"
	rm -rf $(DPDK_BUILD_DIR)
	cd $(DPDK_DIR) && meson setup $(DPDK_BUILD_DIR) -Ddisable_drivers=event/cnxk,net/bnx2x,crypto/openssl -Ddisable_libs=lib/cryptodev -Dc_args='-fPIC' -Dc_link_args='-fPIC' --prefix=$(DPDK_INSTALL_DIR) --libdir=lib --includedir=include --default-library=static
	cd $(DPDK_DIR) && ninja -C $(DPDK_BUILD_DIR) install
endef

dpdk:
	$(call dpdk_21_11)

dpdk-clean:
	if [ -d $(DPDK_DIR)/$(DPDK_BUILD_DIR) ];then ninja -C $(DPDK_DIR)/$(DPDK_BUILD_DIR) clean; fi
	if [ -d $(DPDK_INSTALL_DIR) ];then rm -rf $(DPDK_INSTALL_DIR); fi
	if [ -d $(DPDK_DIR)/$(DPDK_BUILD_DIR) ];then rm -rf $(DPDK_DIR)/$(DPDK_BUILD_DIR); fi


##git clone git@github.com:laitianli/vpp.git && git checkout 2202 -b v2202-debug
define vpp_v2202
	cd $(VPP_DIR) && make build DPDK_PATH=$(DPDK_INSTALL_DIR)
endef

vpp-debug:
	$(call vpp_v2202)


#export DPDK_PATH=$(DPDK_INSTALL_DIR)
define vpp_v2202_release
	cd $(VPP_DIR) && make build-release DPDK_PATH=$(DPDK_INSTALL_DIR)
endef

vpp-release:
	$(call vpp_v2202_release)

vpp-debug-clean:
	cd $(VPP_DIR) && make wipe

vpp-release-clean:
	cd $(VPP_DIR) && make wipe-release

vpp-all-debug:
	cd $(VPP_DIR) && make build

vpp-all-release:
	cd $(VPP_DIR) && make build-release
	

.PHONY: all dpdk  vpp-debug vpp-release vpp-debug-clean vpp-release-clean vpp-all-debug vpp-all-release


clean: dpdk-clean vpp-debug-clean vpp-release-clean
