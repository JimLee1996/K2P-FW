#!/bin/sh
# modify by HuangYingNing at gmail

sudo echo "Starting..."
DIR=`dirname $0`
MKSQSHFS4=${DIR}'/bin/mksquashfs4'
UNSQSHFS4=${DIR}'/bin/unsquashfs4'
PADJFFS2=${DIR}'/bin/padjffs2'
BINWALK=binwalk

FILE_NAME=$2

case "$1" in
'--extract'|'-e')
offset0=0`${BINWALK} ${FILE_NAME} | grep 'uImage header' | awk '{print $1}' | grep -oP '[0-9]*(?= )'`
# offset1=0`${BINWALK} ${FILE_NAME} | grep 'Squashfs filesystem' | awk '{print $1}' | grep -oP '[0-9]*(?= )'`
offset1=0`grep -oba hsqs $2 | grep -oP '[0-9]*(?=:hsqs)'`
offset2=`wc -c ${FILE_NAME} | grep -oP '[0-9]*(?= )'`

#echo "offset0=${offset0} offset1=${offset1} offset2=${offset2} offset2=${offset2}"
size1=`expr ${offset1} - ${offset0}`
size2=`expr $offset2 - $offset1`
#echo $offset1 " " $offset2 " " size1=${size1} size2=$size2
dd if=${FILE_NAME} of=kernel.bin bs=1 ibs=1 count=$offset1
#dd if=${FILE_NAME} of=kernel.bin bs=1 ibs=1 count=$size1 skip=$offset0
dd if=${FILE_NAME} of=secondchunk.bin bs=1 ibs=1 count=$size2 skip=$offset1
sudo rm -rf squashfs-root 2>&1
#sudo unsquashfs -d squashfs-root secondchunk.bin
sudo ${UNSQSHFS4} -d squashfs-root secondchunk.bin
rm secondchunk.bin
;;
'--create'|'-c')
sudo $MKSQSHFS4 ./squashfs-root ./newsecondchunk.bin -nopad -noappend -root-owned -comp xz -Xpreset 9 -Xe -Xlc 0 -Xlp 2 -Xpb 2 -b 256k -processors 1
sudo chown $USER ./newsecondchunk.bin
cat kernel.bin newsecondchunk.bin > ${FILE_NAME}
$PADJFFS2 ${FILE_NAME}
rm newsecondchunk.bin
;;
*)
echo 'run
"modify-firmware.sh extract firmware.bin"
You will find file "kernel.bin" and folder "squashfs-root".
Modify "squashfs-root" as you like,after everything is done,run
"modify-firmware.sh create newfirmware.bin"
And you will get a modified firmware named newfirmware.bin.
'
;;
esac

