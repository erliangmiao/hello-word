if [ -z ${MONTAGE_CHIP} ]; then
	echo -e "you must run \e[0;32msource envsetup \${chip}\e[m to set env MONTAGE_CHIP"
	exit 1
fi


CSTM_DEFCONFIG=$2
BASE_DIR=$PWD
if [ ${MONTAGE_CHIP} = "symphony" ]; then
	#LINUX_PATH=kernel/linux4.4.1
	LINUX_PATH=kernel/linux3.18
else
	LINUX_PATH=kernel/linux3.18
fi
KERNEL_DIR=${BASE_DIR}/${LINUX_PATH}
KWARE_DIR=${BASE_DIR}/kware
COMPONENT_DIR=${BASE_DIR}/component



SDK_DIR=${BASE_DIR}
SDK_LINUX_DIR=${BASE_DIR}/../..
COMMON_DIR=${BASE_DIR}/common
MSP_DIR=${BASE_DIR}/msp
OPENSOURCE_DIR=${SDK_DIR}/opensource

CONFIG_MDRV=y
CFG_MSP_BUILDTYPE=y

if [ ${MONTAGE_CHIP} = "symphony" ]; then
	#use glibc
	if [ "${UCLIBC}" = "uclibc" ]; then
		MUCLIBC="-muclibc"
	fi
	FLOAT=soft-float
	if [ "${FLOAT}" = "soft-float" ]; then
		MFLOAT="-msoft-float"
	fi
	ENDINA=el
	if [ "${ENDINA}" = "el" ]; then
		EL="-EL"
	fi
	LIBC_FLOAT_ENDINA=${UCLIBC}/${FLOAT}/${ENDINA}
fi

if [ ${MONTAGE_CHIP} = "aria" ]; then
	TOOLCHAIN_PATH=/opt/gcc-linaro-arm-linux-gnueabihf/bin
	HOST=arm-linux-gnueabihf
	TOOLCHAIN_SYSROOT=${TOOLCHAIN_PATH}/../${HOST}/libc
	TOOLCHAIN_SUPCXX=${TOOLCHAIN_PATH}/../${HOST}/lib
	TOOLCHAIN_STDCXX=${TOOLCHAIN_SUPCXX}
	TOOLCHAIN_LIBGCC=${TOOLCHAIN_PATH}/../lib/gcc/${HOST}/4.7.3
	ARCH=arm
else
	if [ ${MONTAGE_CHIP} = "symphony" ]; then
		#MIPS_GCC_VERSION="4.3"
		MIPS_GCC_VERSION="5.3"

		ARCH=mips
		HOST=mips-linux-gnu
		if [ ${MIPS_GCC_VERSION} = "5.3" ]; then
			TOOLCHAIN_PATH=/usr/local/codesourcery/mips-2016.05/bin
			TOOLCHAIN_LIBGCC=${TOOLCHAIN_PATH}/../lib/gcc/${HOST}/5.3.0/${LIBC_FLOAT_ENDINA}
		else
			TOOLCHAIN_PATH=/usr/local/codesourcery/mips-4.3/bin
			TOOLCHAIN_LIBGCC=${TOOLCHAIN_PATH}/../lib/gcc/${HOST}/4.3.3/${LIBC_FLOAT_ENDINA}
		fi
		TOOLCHAIN_SYSROOT=${TOOLCHAIN_PATH}/../${HOST}/libc/${LIBC_FLOAT_ENDINA}
		TOOLCHAIN_SUPCXX=${TOOLCHAIN_PATH}/../${HOST}/lib/${LIBC_FLOAT_ENDINA}
		TOOLCHAIN_STDCXX=${TOOLCHAIN_SYSROOT}/usr/lib
	else
		echo "MONTAGE_CHIP error!"
		exit 1
	fi
fi


STATIC_LIB_DIR=${SDK_DIR}/pub/static_lib
SHARED_LIB_DIR=${SDK_DIR}/pub/shared_lib
INCLUDE_DIR=${SDK_DIR}/pub/inc
MODULE_DIR=${SDK_DIR}/pub/ko
BIN_DIR=${SDK_DIR}/pub/bin

mkdir -p ${SDK_DIR}/pub
mkdir -p ${STATIC_LIB_DIR}
mkdir -p ${SHARED_LIB_DIR}
mkdir -p ${INCLUDE_DIR}
mkdir -p ${MODULE_DIR}
mkdir -p ${BIN_DIR}

WB_DIR=${BASE_DIR}/wb
SAMPLE_DIR=${BASE_DIR}/sample
TESTFM_DIR=${BASE_DIR}/testfm
OPTEE_CLIENT_DIR=${BASE_DIR}/kware/optee_client
USR_FS_DIR=${BASE_DIR}/user_fs
DATA_DIR=${BASE_DIR}/data_fs
MONTAGE_TOOLS_DIR=${BASE_DIR}/tools/linux
MKSQUASHFS=${MONTAGE_TOOLS_DIR}/mksquashfs
MKUBIFS=${MONTAGE_TOOLS_DIR}/mkfs.ubifs
MKUBIIMG=${MONTAGE_TOOLS_DIR}/ubinize
SYMPHONY_BIN=${SDK_LINUX_DIR}/../sdkproduct/lotus/solution/app/ui/symphony.bin

export TOOLCHAIN_PATH TOOLCHAIN_SYSROOT TOOLCHAIN_SUPCXX TOOLCHAIN_STDCXX TOOLCHAIN_LIBGCC
export MUCLIBC MFLOAT EL LIBC_FLOAT_ENDINA
export MIPS_GCC_VERSION
export ARCH
export HOST

export KERNEL_DIR KWARE_DIR SDK_DIR OPENSOURCE_DIR COMMON_DIR MSP_DIR CFG_MSP_BUILDTYPE STATIC_LIB_DIR SHARED_LIB_DIR INCLUDE_DIR MODULE_DIR BIN_DIR SAMPLE_DIR WB_DIR TESTFM_DIR BASE_DIR OPTEE_CLIENT_DIR COMPONENT_DIR USR_FS_DIR TOOLS_DIR MKSQUASHFS DATA_DIR MKUBIFS MKUBIIMG SYMPHONY_BIN SDK_LINUX_DIR
export ROOTFS_MDEV_DIR TOOL_DIR BUILD_UIMAGE_SH CONFIG_MDRV
export CSTM_DEFCONFIG
export CFG_MT_DEBUG

check_result()
{
  res=$?

  if [ ! ${res} = "0" ]; then
    echo make $1 failed !!!!!!!!!!! res=${res}
    exit 1
  fi

}




if [ $# -ge 1 ]
 then
  target=$1
 else
 target=all
fi


   make -f ${BASE_DIR}/Makefile ${target}
	 check_result ${target}
