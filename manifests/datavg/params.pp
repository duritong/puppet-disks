# basic parameters
class disks::datavg::params {
  $vg = str2bool($::is_virtual) ? {
    true    => "vdata-${::hostname}",
    default => "data-${::hostname}",
  }

  # compatibility layer
  $vgname = regsubst($vg,'-','_','G')
  $pvs = getvar("::lvm_vg_${vgname}_pvs")
  if $pvs {
    $default_disks = sort(split($pvs,','))
  } else {
    $default_disks = $::virtual ? {
      'virtualbox' => [ '/dev/sdb', ],
      'vmware'     => [ '/dev/sdb', ],
      'physical'   => [ '/dev/sdb', ],
      'xen0'       => [ '/dev/sdb', ],
      'xenU'       => [ '/dev/xvdb', ],
      'kvm'        => [ '/dev/vdb', ],
    }
  }
  $disks = $default_disks
}
