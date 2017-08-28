# basic parameters
class disks::datavg::params {
  $vg = str2bool($::is_virtual) ? {
    true    => "vdata-${::hostname}",
    default => "data-${::hostname}",
  }

  # compatibility layer
  $old_disk = lookup('disks::datavg::disk', { default_value => false })
  $vgname = regsubst($vg,'-','_','G')
  $pvs = getvar("::lvm_vg_${vgname}_pvs")
  if $old_disk {
    notice('DEPRECATION: disks::datavg::disk should be renamed to disks::datavg::disks in you hieradata')
    $disks = [ $old_disk ]
  } else {
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
}
