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
  $disks      = $disks::datavg::params::disks,
  $vg         = $disks::datavg::params::vg,
  $createonly = false,
) inherits disks::datavg::params {

  include ::disks
  disks::pv{$disks: }
  $pvs = suffix($disks,'1')
  volume_group {$vg:
    ensure           => present,
    physical_volumes => $pvs,
    createonly       => $createonly,
    require          => Disks::Pv[$disks],
    before           => Anchor['disks::datavg::finished']
  }

  anchor{'disks::datavg::finished': }
}
