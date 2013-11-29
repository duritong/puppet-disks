# resets owner/group on a mounted dir, as puppet can't do this
# as it manages the directory already before the mount
#
# Parameters:
#  - owner default: root
#  - group default: 0
#  - mode: default: undef -> do not manage the mode
define disks::mount_owner(
  $owner  = 'root',
  $group  = 0,
  $mode   = undef
) {

  exec{"ensure_mount_owner_on_${name}":
    command     => "chown ${owner}:${group} ${name}",
    refreshonly => true,
    subscribe   => Mount[$name]
  }

  if $mode {
    exec{"ensure_mount_mode_on_${name}":
      command     => "chmod ${mode} ${name}",
      refreshonly => true,
      subscribe   => Mount[$name]
    }
  }
}
