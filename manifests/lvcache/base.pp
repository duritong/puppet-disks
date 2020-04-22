# manage lvm cached volumes
class disks::lvcache::base(
  Array[Pattern[/^.*\-..*$/]]
    $cache_vols = [],
){

  if !empty($cache_vols) {
    file{'/usr/local/sbin/lvmcache-stats':
      source => 'puppet:///modules/disks/utils/lvmcache-stats',
      owner  => root,
      group  => 0,
      mode   => '0700',
    }
    munin::plugin::deploy{
      default:
        ensure  => 'absent',
        seltype => 'unconfined_munin_plugin_exec_t';
      'dm_cache_statistics_':
        source => 'disks/munin/dm_cache_statistics_';
      'dm_cache_occupancy_':
        source => 'disks/munin/dm_cache_occupancy_' ;
    }

    $cache_vols.each |$vol| {
      $vol_plugin_name = $vol.gsub(/\-/,'____')
      munin::plugin{
        default:
          config => 'user root';
        "dm_cache_statistics_${vol_plugin_name}":
          ensure  => 'dm_cache_statistics_',
          require => Munin::Plugin::Deploy['dm_cache_statistics_'];
        "dm_cache_occupancy_${vol_plugin_name}":
          ensure  => 'dm_cache_occupancy_',
          require => Munin::Plugin::Deploy['dm_cache_occupancy_'];
      }
    }
  }
}
