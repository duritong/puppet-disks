# utils that are needed for things
# we do with this module
class disks::utils {
  file{'/usr/local/sbin/init_datavg_disk.sh':
    source => 'puppet:///modules/disks/utils/init_datavg_disk.sh',
    owner  => root,
    group  => 0,
    mode   => '0700';
  }
}
