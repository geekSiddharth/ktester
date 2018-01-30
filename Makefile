# Author: Muhammad Falak R Wani [mfrw] <falakreyaz@gmail.com>
# Date  : 2017-11-26
# Kernel Testing script


KDIR=$(shell realpath /kp/)

QEMU_DISPLAY?=none
ARCH?=x86_64

ZIMAGE=$(KDIR)/arch/$(ARCH)/boot/bzImage

KCONFIG=$(KDIR)/.config
YOCTO_URL=http://downloads.yoctoproject.org/releases/yocto/yocto-2.4/machines/qemu/qemu$(ARCH)
#YOCTO_IMAGE=core-image-minimal-dev-qemu$(ARCH).ext4
YOCTO_IMAGE=core-image-minimal-qemu$(ARCH).ext4

ifeq ($(ARCH), x86_64)
YOCTO_URL=http://downloads.yoctoproject.org/releases/yocto/yocto-2.4/machines/qemu/qemux86-64
YOCTO_IMAGE=core-image-minimal-qemux86-64.ext4
ZIMAGE=$(KDIR)/arch/x86/boot/bzImage
endif



QEMU_OPTS = -kernel $(ZIMAGE) \
	    -enable-kvm \
	    -device virtio-serial \
	    -chardev pty,id=virtiocon0 \
	    -device virtconsole,chardev=virtiocon0 \
	    -net nic,model=virtio,vlan=0 \
	    -net tap,ifname=tap0,vlan=0,script=no,downscript=no \
	    -drive file=$(YOCTO_IMAGE),if=virtio,format=raw \
	    --append "root=/dev/vda console=hvc0" \
	    --display $(QEMU_DISPLAY) \
	    -m 512M \
	    -s 

help :
	@echo "make boot For booting the kernel"
	@echo "build for building kernel"
	@echo "copy for copying ...."


boot: .modinst tap0
	ARCH=$(ARCH) qemu/qemu.sh $(QEMU_OPTS)

zImage: $(ZIMAGE)




TMPDIR := $(shell mktemp -u)
.modinst: $(ZIMAGE) $(YOCTO_IMAGE)
	mkdir $(TMPDIR)
	sudo mount -t ext4 -o loop $(YOCTO_IMAGE) $(TMPDIR)
	sudo $(MAKE) -C $(KDIR) modules_install INSTALL_MOD_PATH=$(TMPDIR)
	sudo umount $(TMPDIR)
	rmdir $(TMPDIR)
	sleep 1 && touch .modinst



$(ZIMAGE): $(KCONFIG) $(ZIMAGE)
	$(MAKE) -j8 -C $(KDIR)
	$(MAKE) -j8 -C $(KDIR) modules

conf: $(KCONFIG)
$(KCONFIG): qemu/kernel_config.x86
	cp $^ $@
	$(MAKE) -C $(KDIR) oldnoconfig

$(YOCTO_IMAGE):
	wget $(YOCTO_URL)/$(YOCTO_IMAGE)
	qemu/prepare-image.sh $(YOCTO_IMAGE)

gdb: $(ZIMAGE)
	gdb -ex "target remote localhost:1234" $(KDIR)/vmlinux

tap0:
	qemu/create_net.sh $@


misc:
	mkdir -p misc
	rm -f misc/Kbuild

misc/Kbuild: misc
	echo "#Autogenerated by ktester, do not edit "> $@
	echo "ccflags-y += -Wno-unused-function -Wno-unused-label -Wno-unused-variable " >> $@
	for i in $(shell cd misc && find -mindepth 1 -name Kbuild | xargs dirname); do echo "obj-m += $$i/" >> $@; done

build: $(KCONFIG) misc/Kbuild
	$(MAKE) -C $(KDIR) M=$(PWD)/misc ARCH=$(ARCH) modules
	for i in $(shell find skels -name Makefile | xargs dirname); do $(MAKE) -C $$i; done

COPYDIR := $(shell mktemp -u)
copy: $(YOCTO_IMAGE)
	if [ -e qemu.mon ]; then exit 1; fi
	mkdir $(COPYDIR)
	mount -t ext4 -o loop $(YOCTO_IMAGE) $(COPYDIR)
	cp -rf misc $(COPYDIR)/home/root
#	find misc -type f \( -name *.ko -or -executable \) | xargs sudo cp --parents -t $(COPYDIR)/home/root || true
	umount $(COPYDIR)
	rmdir $(COPYDIR)

clean:
	rm -f .modinst

.PHONY: clean tap0
