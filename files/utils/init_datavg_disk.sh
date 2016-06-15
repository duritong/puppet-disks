#!/bin/bash

if [ -z $1 ]; then
  echo "Usage: $0 /dev/disk"
  exit 1
fi
parted -s $1 mklabel gpt
parted -s $1 mkpart -- primary ext4 1 -1
partprobe $1
ret=$?
int=0
# try at least 3 times to get the partition
while [ $ret -gt 0 ] && [ $int -lt 3 ]; do
  sleep 3
  partprobe $1
  ret=$?
  ((int++))
done
if [ $ret -gt 0  ] && [ -b ${1}1 ]; then
  exit 0
else
  exit $ret
fi

