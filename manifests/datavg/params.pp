# basic parameters
class disks::datavg::params {
  $vg = str2bool($facts['is_virtual']) ? {
    true    => "vdata-${facts['networking']['hostname']}",
    default => "data-${facts['networking']['hostname']}",
  }

  # compatibility layer
  $vgname = regsubst($vg,'-','_','G')
  $pvs = $facts["lvm_vg_${vgname}_pvs"]
  if $pvs {
    $default_disks = sort(split($pvs,','))
  } else {
    $default_disks = $facts['virtual'] ? {
      'virtualbox' => [ '/dev/sdb', ],
      'vmware'     => [ '/dev/sdb', ],
      'physical'   => [ '/dev/sdb', ],
      'xen0'       => [ '/dev/sdb', ],
      'xenU'       => [ '/dev/xvdb', ],
      'kvm'        => [ '/dev/vdb', ],
      # Qubes ibox
      'xen'        => [ '/dev/xvdi', ],
    }
  }
  $disks = $default_disks
}
