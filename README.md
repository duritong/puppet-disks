disks
=====

This is the disks module to manage a data disc for further usage via an lvm.

The basic idea is that our root-disc is only used by data related to the operating system.
Any user related data from services is put onto an own disc, called the datavg.

This module provides the boilerplate for an automatic and streamlined setup of such a disc
for each host.

Usage
-----

The base configuration of the datavg happens in the `disks::datavg` class, which is where
you want to define which disc will become the datavolume and how it will be named.

This will create by default a data volume group called data-$hostname or vdata-$hostname
if you are on a virtualized host.

We assume some reasonable names and a device, but you can fine tune things. Have a look at
the corresponding [class documentation](manifests/datavg.pp)

Create & mount volumes
----------------------

Creating and mounting volumes is quite simple:

    disks::lv_mount{'data':
      size    => '100G'
      folder  => '/data'
    }

This will create a volume of 100G and mount it under /data. For further options have a
look at the [class documentation](manifests/lv_mount.pp)

Support
-------

Please log tickets and issues on [github](https://github.com/duritong/puppet-disks)
