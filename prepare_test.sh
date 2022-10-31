#!/bin/bash
tfs=( ext2 ext2 ext3 ext4) 
sizes=( 10 10 20 20 )

mount_test ()
{
ind=0
for fs in ${tfs[@]} 
do

if [ ! -f /mnt/test_$ind ]; then
 mkdir -p /mnt/test_$ind
fi

dd if=/dev/zero of=test_img${ind} bs=1M count=${sizes[ind]} 
mkfs.${tfs[ind]} test_img$ind
mount -o loop test_img$ind /mnt/test_$ind
ind=$(( ind + 1 ))
done
}

unmount_test ()
{
	lim=$(( ${#tfs[@]} - 1 ))
	while [ "${lim}" -ge 0 ]
	do
	 umount /mnt/test_$lim
	 lim=$(( lim - 1 ))
	done
}

while [ "$1" != "" ]; do
 case $1 in
  -c | --create )
	  echo "Creating test file systems"
	  mount_test
          ;;	  
  -r | --remove )
	  echo "Removing test file systems"
	  unmount_test
	  ;;
  *)
	  echo "Options are not right!"
	  exit 1
  esac
  shift
done
exit 0
