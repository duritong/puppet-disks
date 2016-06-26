require File.expand_path(File.join(File.dirname(__FILE__),'../spec_helper'))

describe 'disks::lv_mount', :type => 'define' do
  let(:title) { 'somedisk' }
  let(:default_facts){
    {
      :is_virtual               => true,
      :selinux                  => true,
      :virtual                  => 'kvm',
      :hostname                 => 'host1',
      :lvm_vg_vdata_host1_pvs => '/dev/sdb1',
    }
  }
  let(:facts){
    default_facts
  }
  context "without size" do
    let(:params){
      {
        :folder   => '/data',
      }
    }
    it do
      expect {
        is_expected.to contain_file('/data')
      }.to raise_error(Puppet::Error, /Must pass \$size to somedisk if present/)
    end
  end
  context "with default" do
    let(:params){
      {
        :folder   => '/data',
        :size     => '1G',
        :owner    => '100',
        :group    => '99',
        :seltype  => 'foo_t'
      }
    }
    it { is_expected.to contain_logical_volume('somedisk').with(
      :ensure        => 'present',
      :volume_group  => 'vdata-host1',
      :size          => '1G',
      :require       => 'Anchor[disks::datavg::finished]'
    )}
    it { is_expected.to contain_filesystem("/dev/vdata-host1/somedisk").with(
      :ensure  => 'present',
      :fs_type => 'ext4',
      :require => 'Logical_volume[somedisk]'
    )}
    it { is_expected.to contain_exec('mkdir /data').with(
      :creates => '/data',
      :before => 'Mount[/data]',
    )}
    it { is_expected.to contain_mount('/data').with(
      :ensure  => 'mounted',
      :atboot  => true,
      :dump    => 1,
      :pass    => 2,
      :fstype  => 'ext4',
      :options => 'defaults',
      :device  => '/dev/vdata-host1/somedisk',
      :require => 'Filesystem[/dev/vdata-host1/somedisk]',
    )}
    it { is_expected.to contain_file('/data').with(
      :ensure   => 'directory',
      :owner    => '100',
      :group    => '99',
      :seltype  => 'foo_t',
      :mode     => nil,
      :require  => 'Mount[/data]'
    )}

    it { is_expected.to contain_exec('restorecon /data').with(
      :refreshonly => true,
      :subscribe   => 'Mount[/data]',
      :before      => 'Anchor[disks::def_diskmount::somedisk::finished]'
    )}
    it { is_expected.to contain_anchor('disks::def_diskmount::somedisk::finished').with(
      :before  => 'Anchor[disks::all_mount_setup]'
    )}
  end

  context 'with mode and mount options' do
    let(:params){
      {
        :folder         => '/data',
        :size           => '11G',
        :owner          => '1001',
        :group          => '991',
        :mode           => '0600',
        :mount_options  => 'defaults,noatime',
        :fs_type        => 'ext3',
        :fs_options     => '-m 100%'
      }
    }
    it { is_expected.to contain_logical_volume('somedisk').with(
      :ensure        => 'present',
      :volume_group  => 'vdata-host1',
      :size          => '11G',
      :require       => 'Anchor[disks::datavg::finished]'
    )}
    it { is_expected.to contain_filesystem("/dev/vdata-host1/somedisk").with(
      :ensure  => 'present',
      :fs_type => 'ext3',
      :options => '-m 100%',
      :require => 'Logical_volume[somedisk]'
    )}
    it { is_expected.to contain_exec('mkdir /data').with(
      :creates => '/data',
      :before => 'Mount[/data]',
    )}
    it { is_expected.to contain_mount('/data').with(
      :ensure  => 'mounted',
      :atboot  => true,
      :dump    => 1,
      :pass    => 2,
      :fstype  => 'ext3',
      :options => 'defaults,noatime',
      :device  => '/dev/vdata-host1/somedisk',
      :require => 'Filesystem[/dev/vdata-host1/somedisk]',
    )}
    it { is_expected.to contain_file('/data').with(
      :ensure   => 'directory',
      :owner    => '1001',
      :group    => '991',
      :mode     => '0600',
      :require  => 'Mount[/data]'
    )}
    it { is_expected.to contain_exec('restorecon /data').with(
      :refreshonly => true,
      :subscribe   => 'Mount[/data]',
      :before      => 'Anchor[disks::def_diskmount::somedisk::finished]'
    )}
    it { is_expected.to contain_anchor('disks::def_diskmount::somedisk::finished').with(
      :before  => 'Anchor[disks::all_mount_setup]'
    )}
  end
  context 'with extents' do
    let(:params){
      {
        :folder         => '/data',
        :size           => '11%VG',
      }
    }
    it { is_expected.to contain_logical_volume('somedisk').with(
      :ensure        => 'present',
      :volume_group  => 'vdata-host1',
      :extents       => '11%VG'
    )}
  end
  context 'with extents 2' do
    let(:params){
      {
        :folder         => '/data',
        :size           => '11%PVS',
      }
    }
    it { is_expected.to contain_logical_volume('somedisk').with(
      :ensure        => 'present',
      :volume_group  => 'vdata-host1',
      :extents       => '11%PVS'
    )}
  end
  context 'with extents 3' do
    let(:params){
      {
        :folder         => '/data',
        :size           => '11%FREE',
      }
    }
    it { is_expected.to contain_logical_volume('somedisk').with(
      :ensure        => 'present',
      :volume_group  => 'vdata-host1',
      :extents       => '11%FREE'
    )}
  end
  context 'with extents 4' do
    let(:params){
      {
        :folder         => '/data',
        :size           => '11%ORIGIN',
      }
    }
    it { is_expected.to contain_logical_volume('somedisk').with(
      :ensure        => 'present',
      :volume_group  => 'vdata-host1',
      :extents       => '11%ORIGIN'
    )}
  end
  context 'with extents 4' do
    let(:params){
      {
        :folder         => '/data',
        :size           => '11%free',
      }
    }
    it { is_expected.to contain_logical_volume('somedisk').with(
      :ensure        => 'present',
      :volume_group  => 'vdata-host1',
      :extents       => '11%free'
    )}
  end
  context 'without folder management' do
    let(:params){
      {
        :folder         => '/data',
        :manage_folder  => false,
        :size           => '11G',
        :owner          => '1001',
        :group          => '991',
        :mode           => '0600',
        :mount_options  => 'defaults,noatime'
      }
    }
    it { is_expected.to contain_logical_volume('somedisk').with(
      :ensure        => 'present',
      :volume_group  => 'vdata-host1',
      :size          => '11G',
      :require       => 'Anchor[disks::datavg::finished]'
    )}
    it { is_expected.to contain_exec('mkdir /data').with(
      :creates => '/data',
      :before => 'Mount[/data]',
    )}
    it { is_expected.to contain_filesystem("/dev/vdata-host1/somedisk").with(
      :ensure  => 'present',
      :fs_type => 'ext4',
      :require => 'Logical_volume[somedisk]'
    )}
    it { is_expected.to contain_mount('/data').with(
      :ensure  => 'mounted',
      :atboot  => true,
      :dump    => 1,
      :pass    => 2,
      :fstype  => 'ext4',
      :options => 'defaults,noatime',
      :device  => '/dev/vdata-host1/somedisk',
    )}
    it { is_expected.to_not contain_file('/data') }
    it { is_expected.to contain_anchor('disks::def_diskmount::somedisk::finished').with(
      :before  => 'Anchor[disks::all_mount_setup]'
    )}
  end
  context 'with absent' do
    let(:params){
      {
        :folder   => '/data',
        :ensure   => 'absent',
      }
    }

    it { is_expected.to contain_mount('/data').with(
      :ensure => 'absent',
      :before => 'Logical_volume[somedisk]'
    )}
    it { is_expected.to contain_logical_volume('somedisk').with(
      :ensure        => 'absent',
      :volume_group  => 'vdata-host1',
      :require       => 'Anchor[disks::datavg::finished]',
      :before  => 'Anchor[disks::def_diskmount::somedisk::finished]'
    )}
    it { is_expected.to_not contain_filesystem("/dev/vdata-host1/somedisk") }
    it { is_expected.to_not contain_exec('mkdir /data') }
    it { is_expected.to contain_exec('rm -rf /data').with(
      :unless  => 'test -d /data',
      :require => 'Logical_volume[somedisk]',
      :before  => 'File[/data]',
    ) }
    it { is_expected.to contain_file('/data').with(
      :ensure  => 'absent',
      :purge   => true,
      :force   => true,
      :recurse => true,
      :before  => 'Anchor[disks::def_diskmount::somedisk::finished]'
    )}
    it { is_expected.to contain_anchor('disks::def_diskmount::somedisk::finished').with(
      :before  => 'Anchor[disks::all_mount_setup]'
    )}
  end

  context 'with absent and not manage folder' do
    let(:params){
      {
        :folder        => '/data',
        :ensure        => 'absent',
        :manage_folder => false,
      }
    }

    it { is_expected.to_not contain_exec('mkdir /data') }
    it { is_expected.to contain_mount('/data').with(
      :ensure => 'absent',
      :before => 'Logical_volume[somedisk]'
    )}
    it { is_expected.to contain_logical_volume('somedisk').with(
      :ensure        => 'absent',
      :volume_group  => 'vdata-host1',
      :require       => 'Anchor[disks::datavg::finished]',
      :before  => 'Anchor[disks::def_diskmount::somedisk::finished]'
    )}
    it { is_expected.to_not contain_filesystem("/dev/vdata-host1/somedisk") }
    it { is_expected.to_not contain_file('/data') }
    it { is_expected.to_not contain_exec('rm -rf /data') }
    it { is_expected.to contain_anchor('disks::def_diskmount::somedisk::finished').with(
      :before  => 'Anchor[disks::all_mount_setup]'
    )}
  end
end

