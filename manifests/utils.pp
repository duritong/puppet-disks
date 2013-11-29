# utils that are needed for things
# we do with this module
class disks::utils {
  file{'/usr/local/sbin/init_datavg_disk.sh':
    content => "#!/bin/bash

if [ -z \$1 ]; then
  echo \"Usage: \$0 /dev/disk\"
  exit 1
fi
parted -s \$1 mklabel gpt
parted -s \$1 mkpart -- primary ext4 1 -1
partprobe \$1
",
    owner   => root,
    group   => 0,
    mode    => '0700';
  }
}
