# initializes a disk to be used as a
# physical volume
define disks::pv() {

  include disks::utils
  exec{"make_${name}":
    command  => "/usr/local/sbin/init_datavg_disk.sh ${name}",
    unless   => "test -b ${name}1",
    notify   => Exec["partprobe_${name}"],
    require  => File['/usr/local/sbin/init_datavg_disk.sh'],
  }

  exec{"partprobe_${name}":
    command     => "partprobe ${name}",
    refreshonly => true,
  }

  physical_volume { "${name}1":
    ensure  => present,
    require => Exec["partprobe_${name}"]
  }
}
