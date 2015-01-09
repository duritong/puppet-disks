# a basic and convinient way to setup a volume on the
# datavg and its corresponding mountpoint
#
# Parameters:
#
#  - size: of the Volume
#  - folder: Where to mount that volume
#  - owner: default: root
#  - group: default: 0
#  - mode: default: 0755
#  - manage_folder: Should the folder itself be created?
#                   default: true
#  - mount_options: default: defaults
#
define disks::lv_mount(
  $size,
  $folder,
  $owner          = undef,
  $group          = undef,
  $mode           = undef,
  $seltype        = undef,
  $manage_folder  = true,
  $mount_options  = 'defaults',
  $fs_type        = 'ext4',
){

  include disks::datavg
  $vg = $disks::datavg::vg

  logical_volume{$name:
    ensure       => present,
    volume_group => $vg,
    size         => $size,
    require      => Anchor['disks::datavg::finished'],
  } -> filesystem{"/dev/${vg}/${name}":
    ensure  => present,
    fs_type => $fs_type,
  }
  if $manage_folder {
    file{$folder:
      ensure  => directory,
      owner   => $owner,
      group   => $group,
      mode    => $mode,
      seltype => $seltype,
    }
  }
  mount{$folder:
    ensure  => 'mounted',
    atboot  => true,
    dump    => 1,
    pass    => 2,
    fstype  => $fs_type,
    options => $mount_options,
    device  => "/dev/${vg}/${name}",
    require => [ File[$folder], Filesystem["/dev/${vg}/${name}"] ];
  }

  if str2bool($::selinux) {
    exec{"restorecon ${folder}":
      refreshonly => true,
      subscribe   => Mount[$folder],
      before      => Anchor["disks::def_diskmount::${name}::finished"],
    }
    if $seltype {
      exec{"chcon -t ${seltype} ${folder}":
        refreshonly => true,
        subscribe   => Mount[$folder],
        before      => Anchor["disks::def_diskmount::${name}::finished"],
      }
    }
  }

  disks::mount_owner{$folder:
    owner   => $owner,
    group   => $group,
    mode    => $mode,
    require => Mount[$folder];
  } -> anchor{"disks::def_diskmount::${name}::finished":
    before  => Anchor['disks::all_mount_setup']
  }
}
