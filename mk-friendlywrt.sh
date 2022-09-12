#!/bin/bash

set -u

SCRIPTS_DIR=$(cd `dirname $0`; pwd)
if [ -h $0 ]
then
        CMD=$(readlink $0)
        SCRIPTS_DIR=$(dirname $CMD)
fi
cd $SCRIPTS_DIR
cd ../
TOP_DIR=$(pwd)

TARGET_FRIENDLYWRT_CONFIG=$1
FRIENDLYWRT_SRC_PATHNAME=$2
echo "============Start building friendlywrt============"
echo "TARGET_FRIENDLYWRT_CONFIG = $TARGET_FRIENDLYWRT_CONFIG"
echo "FRIENDLYWRT_SRC_PATHNAME = $FRIENDLYWRT_SRC_PATHNAME"
echo "=========================================="

cd ${TOP_DIR}/${FRIENDLYWRT_SRC_PATHNAME}
./scripts/feeds update -a
./scripts/feeds install -a
if [ ! -f .config ]; then
	cp ${TOP_DIR}/configs/${TARGET_FRIENDLYWRT_CONFIG} .config
	make defconfig
else
	echo "using .config file"
fi

if [ ! -d dl ]; then
	# FORTEST
	# cp -af /opt4/openwrt-full-dl ./dl
	echo "dl directory doesn't  exist. Will make download full package from openwrt site."
fi
make download -j$(nproc)

USING_DATE=$(date +%Y%m%d)
echo "${USING_DATE}" > ./package/base-files/files/etc/rom-version

make package/po2lmo/compile V=99
RET=$?
if [ $RET -eq 0 ]; then
	exit 0
fi

make package/po2lmo/compile V=s
RET=$?
if [ $RET -eq 0 ]; then
    exit 0
fi

exit 1
