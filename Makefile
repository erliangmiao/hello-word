.EXPORT_ALL_VARIABLES:



include base.mk

CFG_MT_EXPORT_FLAG=y

PHONY: help


.PHONY: all kernel kernel_clean \
        opensource opensource_clean opensource_install opensource_uninstall \
        kware_base kware_base_clean kware_base_install kware_base_uninstall \
        kware kware_clean kware_install kware_uninstall \
        common common_clean common_install  common_uninstall \
        msp msp_clean msp_install msp_uninstall \
        comp comp_clean comp_install comp_uninstall \
        testfm testfm_clean testfm_install testfm_uninstall \
        sample sample_clean wb gstav wb_clean help mall \
        optee_client mclean muninstall flash fs

all: help

help:
	@echo "valid target:"
	@echo "kernel kernel_clean"
	@echo "opensource opensource_clean opensource_install opensource_uninstall"
	@echo "kware_base kware_base_clean kware_base_install kware_base_uninstall"
	@echo "kware kware_clean kware_install kware_uninstall"
	@echo "comp comp_clean comp_install comp_uninstall"
	@echo "common common_clean common_install common_uninstall"
	@echo "msp msp_clean msp_install msp_uninstall"
	@echo "testfm testfm_clean testfm_install testfm_uninstall"
	@echo "sample mall optee_client"
	@echo "wb"
	@echo "gstav"

kernel:
	@echo " ROOTFS_CPIO_NAME is ${ROOTFS_CPIO_NAME}, ROOTFS_MDEV_DIR is ${ROOTFS_MDEV_DIR}"
	@echo ${KERNEL_DIR}
ifneq (${CONFIG_MDRV},n)
	cd ${KERNEL_DIR}/drivers && rm -rf common && ln -s ${BASE_DIR}/common/drv ./common && cd -
	cd ${KERNEL_DIR}/drivers && rm -rf msp && ln -s ${BASE_DIR}/msp/drv ./msp && cd -
endif
ifeq (${MONTAGE_CHIP},aria)
	make -C ${KERNEL_DIR} ARCH=arm CROSS_COMPILE=${CONFIG_CROSS_COMPILE} aria_defconfig
	make -C ${KERNEL_DIR} CONFIG_MDRV=${CONFIG_MDRV}  ARCH=arm CROSS_COMPILE=${CONFIG_CROSS_COMPILE} dtbs
	make -C ${KERNEL_DIR} CONFIG_MDRV=${CONFIG_MDRV}  ARCH=arm CROSS_COMPILE=${CONFIG_CROSS_COMPILE} uImage -j4
	make -C ${KERNEL_DIR} CONFIG_MDRV=${CONFIG_MDRV}  ARCH=arm CROSS_COMPILE=${CONFIG_CROSS_COMPILE} uImage-dtb -j4
	make -C ${KERNEL_DIR} CONFIG_MDRV=${CONFIG_MDRV}  ARCH=arm CROSS_COMPILE=${CONFIG_CROSS_COMPILE} modules
else
ifeq (${MONTAGE_CHIP},symphony)
	make -C ${KERNEL_DIR} ARCH=mips CROSS_COMPILE=${CONFIG_CROSS_COMPILE} symphony_defconfig
	make -C ${KERNEL_DIR} CONFIG_MDRV=${CONFIG_MDRV} ARCH=mips CROSS_COMPILE=${CONFIG_CROSS_COMPILE} -j4
	cd ${KERNEL_DIR}; ./arch/mips/montage/build_symphony_image.sh; cd -
endif
endif

kernel_android:
	#echo " ROOTFS_CPIO_NAME is ${ROOTFS_CPIO_NAME}, ROOTFS_MDEV_DIR is ${ROOTFS_MDEV_DIR}"
	rm -rf ${KERNEL_DIR}/mdev.cpio
ifneq (${CONFIG_MDRV},n)
	cd ${KERNEL_DIR}/drivers && rm -rf common && ln -s ${BASE_DIR}/common/drv ./common && cd -
	cd ${KERNEL_DIR}/drivers && rm -rf msp && ln -s ${BASE_DIR}/msp/drv ./msp && cd -
endif
	@echo ${KERNEL_DIR}
	#cp -rf ${KERNEL_DIR}/arch/arm/boot/dts/aria_android.dtsi ${KERNEL_DIR}/arch/arm/boot/dts/aria.dtsi
	#cp -rf ${KERNEL_DIR}/arch/arm/boot/dts/aria_android.dts ${KERNEL_DIR}/arch/arm/boot/dts/aria.dts
	#make -C ${KERNEL_DIR} ARCH=arm CROSS_COMPILE=${CONFIG_CROSS_COMPILE} aria_android_defconfig
	make -C ${KERNEL_DIR} ARCH=arm CROSS_COMPILE=${CONFIG_CROSS_COMPILE} ${CSTM_DEFCONFIG}
	make -C ${KERNEL_DIR} CONFIG_MDRV=${CONFIG_MDRV}  CFG_ANDROID_PRODUCT=y  ARCH=arm CROSS_COMPILE=${CONFIG_CROSS_COMPILE} dtbs
	make -C ${KERNEL_DIR} CONFIG_MDRV=${CONFIG_MDRV}  CFG_ANDROID_PRODUCT=y  ARCH=arm CROSS_COMPILE=${CONFIG_CROSS_COMPILE} uImage -j4
	make -C ${KERNEL_DIR} CONFIG_MDRV=${CONFIG_MDRV}  CFG_ANDROID_PRODUCT=y  ARCH=arm CROSS_COMPILE=${CONFIG_CROSS_COMPILE} uImage-dtb -j4
	make -C ${KERNEL_DIR} CONFIG_MDRV=${CONFIG_MDRV}  CFG_ANDROID_PRODUCT=y  ARCH=arm CROSS_COMPILE=${CONFIG_CROSS_COMPILE} modules

kernel_emu:
	echo " ROOTFS_CPIO_NAME is ${ROOTFS_CPIO_NAME}, ROOTFS_MDEV_DIR is ${ROOTFS_MDEV_DIR}"
	rm -rf ${KERNEL_DIR}/mdev.cpio
ifneq (${CONFIG_MDRV},n)
	cd ${KERNEL_DIR}/drivers && rm -rf common && ln -s ${BASE_DIR}/common/drv ./common && cd -
	cd ${KERNEL_DIR}/drivers && rm -rf msp && ln -s ${BASE_DIR}/msp/drv ./msp && cd -
endif
	@echo ${KERNEL_DIR}
	make  -C ${KERNEL_DIR} CONFIG_MDRV=${CONFIG_MDRV} distclean
	cp -rf ${KERNEL_DIR}/arch/arm/boot/dts/aria_emu.dtsi ${KERNEL_DIR}/arch/arm/boot/dts/aria.dtsi
	make -C ${KERNEL_DIR} ARCH=arm CROSS_COMPILE=${CONFIG_CROSS_COMPILE} aria_emu_defconfig
	make -C ${KERNEL_DIR} CONFIG_MDRV=${CONFIG_MDRV} CONFIG_EMU=y  ARCH=arm CROSS_COMPILE=${CONFIG_CROSS_COMPILE} dtbs
	make -C ${KERNEL_DIR} CONFIG_MDRV=${CONFIG_MDRV} CONFIG_EMU=y  ARCH=arm CROSS_COMPILE=${CONFIG_CROSS_COMPILE} uImage -j4
	make -C ${KERNEL_DIR} CONFIG_MDRV=${CONFIG_MDRV} CONFIG_EMU=y  ARCH=arm CROSS_COMPILE=${CONFIG_CROSS_COMPILE} uImage-dtb -j4
	make -C ${KERNEL_DIR} CONFIG_MDRV=${CONFIG_MDRV} CONFIG_EMU=y  ARCH=arm CROSS_COMPILE=${CONFIG_CROSS_COMPILE} modules

kernel_clean:
	@echo ${KERNEL_DIR}
	@if [ -d "${KERNEL_DIR}/drivers/common" -a -d "${KERNEL_DIR}/drivers/msp" ]; then \
		make  -C ${KERNEL_DIR} CONFIG_MDRV=${CONFIG_MDRV} CROSS_COMPILE=${CONFIG_CROSS_COMPILE} clean; \
		rm -rf ${KERNEL_DIR}/drivers/common; \
		rm -rf ${KERNEL_DIR}/drivers/msp; \
	else \
		make  -C ${KERNEL_DIR} CONFIG_MDRV=n CROSS_COMPILE=${CONFIG_CROSS_COMPILE} clean; \
	fi
ifneq (${CONFIG_MDRV},n)
	make -C ${MSP_DIR}/drv CONFIG_MDRV=${CONFIG_MDRV} CROSS_COMPILE=${CONFIG_CROSS_COMPILE} clean
	make -C ${COMMON_DIR}/drv CONFIG_MDRV=${CONFIG_MDRV} CROSS_COMPILE=${CONFIG_CROSS_COMPILE} clean
endif


opensource:
	@echo OPENSOURCE ${OPENSOURCE_DIR}
	make  -C ${OPENSOURCE_DIR}

opensource_install:
	@echo OPENSOURCE ${OPENSOURCE_DIR}
	make  -C ${OPENSOURCE_DIR} install

opensource_uninstall:
	@echo OPENSOURCE ${OPENSOURCE_DIR}
	make  -C ${OPENSOURCE_DIR}  uninstall

opensource_clean:
	@echo OPENSOURCE ${OPENSOURCE_DIR}
	make  -C ${OPENSOURCE_DIR}  clean



kware_base:
	@echo KWARE ${KWARE_DIR} 1
	make  -C ${KWARE_DIR} STEP=1 -j4

kware_base_install:
	@echo KWARE ${KWARE_DIR} 1
	make  -C ${KWARE_DIR} STEP=1 install

kware_base_uninstall:
	@echo KWARE ${KWARE_DIR} 1
	make  -C ${KWARE_DIR} STEP=1 uninstall

kware_base_clean:
	@echo KWARE ${KWARE_DIR} 1
	make  -C ${KWARE_DIR} STEP=1 clean
	make  -C ${KWARE_DIR} STEP=1 distclean

kware:
	@echo KWARE ${KWARE_DIR} 2
	make  -C ${KWARE_DIR} STEP=2 -j4

kware_install:
	@echo KWARE ${KWARE_DIR} 2
	make  -C ${KWARE_DIR} STEP=2 install

kware_uninstall:
	@echo KWARE ${KWARE_DIR} 2
	make  -C ${KWARE_DIR} STEP=2 uninstall

kware_clean:
	@echo KWARE ${KWARE_DIR} 2
	make  -C ${KWARE_DIR} STEP=2 clean
	make  -C ${KWARE_DIR} STEP=2 distclean

kware_dfb:
	@echo KWARE ${KWARE_DIR} 3
	make  -C ${KWARE_DIR} STEP=3 -j4

kware_dfb_install:
	@echo KWARE ${KWARE_DIR} 3
	make  -C ${KWARE_DIR} STEP=3 install

kware_dfb_uninstall:
	@echo KWARE ${KWARE_DIR} 3
	make  -C ${KWARE_DIR} STEP=3 uninstall

kware_dfb_clean:
	@echo KWARE ${KWARE_DIR} 3
	make  -C ${KWARE_DIR} STEP=3 clean
	make  -C ${KWARE_DIR} STEP=3 distclean

comp:
	@echo comp ${COMPONENT_DIR}
	make  -C ${COMPONENT_DIR} -j4

comp_install:
	@echo comp ${COMPONENT_DIR}
	make  -C ${COMPONENT_DIR} install

comp_uninstall:
	@echo comp ${COMPONENT_DIR}
	make  -C ${COMPONENT_DIR} uninstall

comp_clean:
	@echo comp ${COMPONENT_DIR}
	make  -C ${COMPONENT_DIR} clean
	make  -C ${COMPONENT_DIR} distclean

sample:
	make  -C ${SAMPLE_DIR} -j4

sample_install:
	make  -C ${SAMPLE_DIR} install

sample_uninstall:
	make  -C ${SAMPLE_DIR} uninstall

sample_clean:
	make  -C ${SAMPLE_DIR} clean

#just for gst player
gstav:
ifeq ($(CFG_MT_GST_SUPLAYER_SUPPORT),y)
	@echo gst avinstance
	make  -C  kware/libmonplayer/avplay_instance
endif

wb:
	make  -C ${WB_DIR} -j4

wb_install:
	make  -C ${WB_DIR} install

wb_uninstall:
	make  -C ${WB_DIR} uninstall

wb_clean:
	make  -C ${WB_DIR} clean

common:
	make  -C ${COMMON_DIR} -j4

common_install:
	make  -C ${COMMON_DIR} install

common_uninstall:
	make  -C ${COMMON_DIR} uninstall

common_clean:
	make  -C ${COMMON_DIR} clean

msp:
	make  -C ${MSP_DIR} -j4

msp_install:
	make  -C ${MSP_DIR} install

msp_uninstall:
	make  -C ${MSP_DIR} uninstall

msp_clean:
	make  -C ${MSP_DIR} clean

testfm:
	make  -C ${TESTFM_DIR}

testfm_install:
	make  -C ${TESTFM_DIR} install

testfm_uninstall:
	make  -C ${TESTFM_DIR} uninstall

testfm_clean:
	make  -C ${TESTFM_DIR} clean

optee_client:
	make  -C ${OPTEE_CLIENT_DIR}

optee_client_clean:
	make  -C ${OPTEE_CLIENT_DIR} clean

optee_client_install:
	make  -C ${OPTEE_CLIENT_DIR} install

fs:
	@echo "create user fs"
	@if [ -d ${USR_FS_DIR} ]; then rm -rf $(USR_FS_DIR); fi;
	@mkdir -p $(USR_FS_DIR)/wifi
	@mkdir -p $(USR_FS_DIR)/config
#	copy content to dest director blow
	#@cp $(SDK_LINUX_DIR)/../sdkproduct/lotus/solution/app/ui/rosemary/binary/ota_binary/ir0.bin $(USR_FS_DIR)/config -f
	#@cp $(SDK_LINUX_DIR)/../sdkproduct/lotus/solution/app/ui/rosemary/binary/ota_binary/ir1.bin $(USR_FS_DIR)/config -f
	#@cp $(SDK_LINUX_DIR)/../sdkproduct/lotus/solution/app/ui/rosemary/binary/ota_binary/ir2.bin $(USR_FS_DIR)/config -f
	#@cp $(SDK_LINUX_DIR)/../sdkproduct/lotus/solution/app/ui/rosemary/binary/ota_binary/fp.bin $(USR_FS_DIR)/config -f
	#@cp $(SDK_LINUX_DIR)/../sdkproduct/lotus/solution/app/ui/rosemary/binary/ota_binary/fp_cfg.bin $(USR_FS_DIR)/config -f
	#@cp $(SDK_LINUX_DIR)/../sdkproduct/lotus/solution/app/ui/rosemary/binary/ota_binary/hdcpkey.bin $(USR_FS_DIR)/config -f
	#@cp $(SDK_LINUX_DIR)/../sdkproduct/lotus/solution/app/ui/rosemary/binary/ota_binary/hw_cfg.bin $(USR_FS_DIR)/config -f
	#@cp $(SDK_LINUX_DIR)/../sdkproduct/lotus/solution/app/ui/rosemary/binary/ota_binary/identity.bin $(USR_FS_DIR)/config -f
	#@cp $(SDK_LINUX_DIR)/../sdkproduct/lotus/solution/app/ui/rosemary/binary/ota_binary/mac_addr.bin $(USR_FS_DIR)/config -f	
	#@cp $(SDK_LINUX_DIR)/../sdkproduct/lotus/solution/app/ui/rosemary/binary/rsc_8m.bin.lzma $(USR_FS_DIR)/config -f
	#@cp $(SDK_LINUX_DIR)/../sdkproduct/lotus/make/start.sh $(USR_FS_DIR)	
	#@cp $(SDK_LINUX_DIR)/../sdkproduct/lotus/solution/app/ui/rosemary/binary/ss_data.bin	$(USR_FS_DIR)
	@cp $(SHARED_LIB_DIR)/libcupnp.so  $(USR_FS_DIR)/wifi -af 
	@cp $(SHARED_LIB_DIR)/libexpat.so  $(USR_FS_DIR)/wifi -af
	@cp $(SHARED_LIB_DIR)/libnl-3.so  $(USR_FS_DIR)/wifi -af
	@cp $(SHARED_LIB_DIR)/libnl-3.so.200  $(USR_FS_DIR)/wifi -af
	@cp $(SHARED_LIB_DIR)/libnl-3.so.200.20.0  $(USR_FS_DIR)/wifi -af
	@cp $(SHARED_LIB_DIR)/libnl-genl-3.so  $(USR_FS_DIR)/wifi -af
	@cp $(SHARED_LIB_DIR)/libnl-genl-3.so.200  $(USR_FS_DIR)/wifi -af
	@cp $(SHARED_LIB_DIR)/libnl-genl-3.so.200.20.0  $(USR_FS_DIR)/wifi -af
	#@cp $(BIN_DIR)/dlna_dmr $(USR_FS_DIR)/wifi -af
	@cp $(MODULE_DIR)/8188eu.ko $(USR_FS_DIR)/wifi -f
	@cp $(MODULE_DIR)/m88wi6700u.ko $(USR_FS_DIR)/wifi -f
	@cp $(MODULE_DIR)/MT7601USTA.dat $(USR_FS_DIR)/wifi -f
	@cp $(MODULE_DIR)/mt7601Usta.ko  $(USR_FS_DIR)/wifi -f
	@cp $(SHARED_LIB_DIR)/libmtwlansta.so $(USR_FS_DIR)/wifi -f
	@cp $(BIN_DIR)/wpa_supplicant $(USR_FS_DIR)/wifi -f
	@cp $(BIN_DIR)/wpa_cli $(USR_FS_DIR)/wifi -f
	#@cp $(BIN_DIR)/mtwlan_demo $(USR_FS_DIR)/wifi -f
	@cp $(BIN_DIR)/wdrv.cfg $(USR_FS_DIR)/wifi -f
	#@if [ -f ${SYMPHONY_BIN} ]; then \
	#	 cp $(SYMPHONY_BIN) $(USR_FS_DIR);\
	#	 $(STRIP) $(USR_FS_DIR)/symphony.bin;\
	#fi;
	$(BASE_DIR)/tools/linux/mksquashfs $(USR_FS_DIR) usrfs.img
	mv usrfs.img $(BASE_DIR)/image/ -f
	@echo $(DATA_DIR)
	@if [ -d ${DATA_DIR} ]; then rm -rf $(DATA_DIR); fi;
	@mkdir -p $(DATA_DIR)
	@echo "make datafs in ubi mode"
	$(MKUBIFS) -r $(DATA_DIR) -m 1 -e 65408 -c 32 -o $(BASE_DIR)/image/ubifs.img
	$(MKUBIIMG) -o ubi.img -p 65536 -m 1 -s 1 $(BASE_DIR)/tools/linux/ubinize.cfg
	@mv ubi.img $(BASE_DIR)/image/ -f
#yiyuan add for dongle case
donglefs:
	$(BASE_DIR)/tools/linux/mksquashfs $(BASE_DIR)/image/dongle/usrfs $(BASE_DIR)/image/dongle/usrfs.img
dongleflash:
	##copy kernel to $(BASE_DIR)/image/dongle/
	cp -f $(KERNEL_DIR)/arch/mips/boot/uImage $(BASE_DIR)/image/dongle/uImage
	perl $(BASE_DIR)/image/dongle/flashbin_glibc.pl -o $(BASE_DIR)/image/dongle/flash_ddr2_128_16M_spinor.bin -d $(BASE_DIR)/image/dongle/ -u $(BASE_DIR)/image/dongle/usrfs.img


flash: fs 
	cp -f $(KERNEL_DIR)/arch/mips/boot/uImage $(BASE_DIR)/image/uImage
	cp -f $(BASE_DIR)/av_rtos/platform/source/firmware/symphony_avcpu/av_test.bin $(BASE_DIR)/image/av_cpu.bin
	cp -f $(BASE_DIR)/av_rtos/platform/source/firmware/symphony_avcpu/av_test_256m.bin $(BASE_DIR)/image/av_cpu256m.bin
	cp -f $(BASE_DIR)/tools/symphony/btinit_ddr2_400m.img $(BASE_DIR)/image/btinit_ddr2_400m.img
	cp -f $(BASE_DIR)/tools/symphony/btinit_ddr3_666m.img $(BASE_DIR)/image/btinit_ddr3_666m.img
	cp -f $(BASE_DIR)/tools/symphony/uboot_linux.img $(BASE_DIR)/image/uboot_linux.img
	perl $(BASE_DIR)/tools/linux/ddr2_128_16M_flashbin.pl -o $(BASE_DIR)/image/flash_ddr2_128_16M_spinor.bin -d $(BASE_DIR)/image -u $(BASE_DIR)/image/usrfs.img -j $(BASE_DIR)/image/ubi.img
	perl $(BASE_DIR)/tools/linux/ddr2_128_8M_flashbin.pl -o $(BASE_DIR)/image/flash_ddr2_128_8M_spinor.bin -d $(BASE_DIR)/image -u $(BASE_DIR)/image/usrfs.img
	perl $(BASE_DIR)/tools/linux/ddr3_128_8M_flashbin.pl -o $(BASE_DIR)/image/flash_ddr3_128_8M_spinor.bin -d $(BASE_DIR)/image -u $(BASE_DIR)/image/usrfs.img
	perl $(BASE_DIR)/tools/linux/ddr3_256_8M_flashbin.pl -o $(BASE_DIR)/image/flash_ddr3_256_8M_spinor.bin -d $(BASE_DIR)/image -u $(BASE_DIR)/image/usrfs.img
	perl $(BASE_DIR)/tools/linux/ddr3_256_16M_flashbin.pl -o $(BASE_DIR)/image/flash_ddr3_256_16M_spinor.bin -d $(BASE_DIR)/image -u $(BASE_DIR)/image/usrfs.img -j $(BASE_DIR)/image/ubi.img
	perl $(BASE_DIR)/tools/linux/ddr3_256_16M_hdcp_intkey_flashbin.pl -o $(BASE_DIR)/image/flash_ddr3_256_16M_intkey_spinor.bin -d $(BASE_DIR)/image -u $(BASE_DIR)/image/usrfs.img -j $(BASE_DIR)/image/ubi.img
	perl $(BASE_DIR)/tools/linux/ddr3_256_16M_hdcp_extkey_flashbin.pl -o $(BASE_DIR)/image/flash_ddr3_256_16M_extkey_spinor.bin -d $(BASE_DIR)/image -u $(BASE_DIR)/image/usrfs.img -j $(BASE_DIR)/image/ubi.img

mclean: kernel_clean testfm_clean msp_clean common_clean sample_clean kware_base_clean kware_clean kware_dfb_clean wb_clean comp_clean

muninstall: opensource_uninstall common_uninstall kware_base_uninstall msp_uninstall kware_uninstall kware_dfb_uninstall testfm_uninstall comp_uninstall sample_uninstall wb_uninstall

#mall: kernel common common_install kware_base kware_base_install msp msp_install kware kware_install testfm testfm_install comp comp_install sample wb gstav

mall: kernel opensource opensource_install common common_install kware_base kware_base_install msp msp_install kware kware_install kware_dfb kware_dfb_install testfm testfm_install comp comp_install sample sample_install wb wb_install
