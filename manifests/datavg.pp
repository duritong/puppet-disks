# Sets up the datavg on the additional disk
#
# It will initialize the disc and create the specified
# volume group on it.
#
# Note: It will only create the volumegroup, but won't
#       manage it further. This means that you can
#       manually
#
# Parameters:
#
#  - disk: Which disk to initialize
#  - vg: The name of your datavg
#  - createonly: Whether to only create the VG or also manage it
#
# Anchors:
#  disks::datavg::finished - Used to anchor everything that should happen
#                            after all volumes are initialized
class disks::datavg(
  $disk       = $::virtual ? {
    'vmware'    => '/dev/sdb',
    'physical'  => '/dev/sdb',
    'xen0'      => '/dev/sdb',
    'xenU'      => '/dev/xvdb',
    'kvm'       => '/dev/vdb',
  },
  $vg         = str2bool($::is_virtual) ? {
    true    => "vdata-${::hostname}",
    default => "data-${::hostname}",
  },
  $createonly = false,
) {

  include ::disks
  disks::pv{$disk: }
  volume_group {$vg:
    ensure           => present,
    physical_volumes => "${disk}1",
    createonly       => $createonly,
    require          => Disks::Pv[$disk],
    before           => Anchor['disks::datavg::finished']
  }

  anchor{'disks::datavg::finished': }
}
