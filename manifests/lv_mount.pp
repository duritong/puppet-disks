# a basic and convenient way to setup a volume on the
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
  $folder,
  $size           = undef,
  $owner          = undef,
  $group          = undef,
  $mode           = undef,
  $seltype        = undef,
  $manage_folder  = true,
  $mount_options  = 'defaults',
  $fs_type        = 'ext4',
  $fs_options     = undef,
  $ensure         = 'present',
){

  include disks::datavg
  $vg = $disks::datavg::vg

  logical_volume{$name:
    ensure       => $ensure,
    volume_group => $vg,
    require      => Anchor['disks::datavg::finished'],
  }
  if $manage_folder {
    file{$folder: }
  }
  mount{$folder: }
  if $ensure == 'present' {
    if !$size { fail("Must pass \$size to ${name} if present") }
    if $size =~ /^\d+%(?i:vg|pvs|free|origin)$/ {
      Logical_volume[$name]{
        extents => $size
      }
    } else {
      Logical_volume[$name]{
        size => $size
      }
    }
    filesystem{"/dev/${vg}/${name}":
      ensure  => present,
      fs_type => $fs_type,
      require => Logical_volume[$name],
    }
    if $fs_options {
      Filesystem["/dev/${vg}/${name}"]{
        options => $fs_options
      }
    }
    exec{"mkdir ${folder}":
      creates => $folder,
      before  => Mount[$folder],
    }
    Mount[$folder]{
      ensure  => 'mounted',
      atboot  => true,
      dump    => 1,
      pass    => 2,
      fstype  => $fs_type,
      options => $mount_options,
      device  => "/dev/${vg}/${name}",
      require => Filesystem["/dev/${vg}/${name}"],
    }
    if $manage_folder {
      File[$folder]{
        ensure  => directory,
        owner   => $owner,
        group   => $group,
        mode    => $mode,
        seltype => $seltype,
        require => Mount[$folder],
      }
    }

    if str2bool($::selinux) {
      exec{"restorecon ${folder}":
        refreshonly => true,
        subscribe   => Mount[$folder],
        before      => Anchor["disks::def_diskmount::${name}::finished"],
      }
    }
  } else {
    Mount[$folder]{
      ensure => 'absent',
      before => Logical_volume[$name]
    }
    Logical_volume[$name]{
      before => Anchor["disks::def_diskmount::${name}::finished"]
    }
    if $manage_folder {
      exec{"rm -rf ${folder}":
        unless  => "test -d ${folder}",
        require => Logical_volume[$name],
        before  => File[$folder],
      }
      File[$folder]{
        ensure  => absent,
        force   => true,
        purge   => true,
        recurse => true,
        before  => Anchor["disks::def_diskmount::${name}::finished"]
      }
    }

  }
  anchor{"disks::def_diskmount::${name}::finished":
    before  => Anchor['disks::all_mount_setup']
  }
}
