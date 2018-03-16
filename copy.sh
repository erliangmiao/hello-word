#!/bin/bash

cp  ./linux/av_rtos/platform/source/firmware/symphony_avcpu/av_test.bin         ~/nfs
cp  ./linux/av_rtos/platform/source/firmware/symphony_avcpu/av_test_256m.bin    ~/nfs



cp ./linux/kernel/linux3.18/arch/mips/boot/uImage    ~/nfs

cp ./linux/sample/esplay/sample_esplay  ~/nfs
cp ./linux/sample/gstsuplayer/test_suplayer       ~/nfs
cp ./linux/sample/suplayer/suplayer              ~/nfs

cp ./linux/sample/frontend/sample_frontend       ~/nfs
cp ./linux/sample/frontend/sample_frontend_dvbc  ~/nfs
cp ./linux/sample/demux/sample_ca_dvbplay        ~/nfs
cp ./linux/wb/sample_wb                          ~/nfs

