require File.expand_path(File.join(File.dirname(__FILE__),'../spec_helper'))

describe 'disks::lv_mount', :type => 'define' do
  let(:title) { 'somedisk' }
  let(:facts){
    {
      :is_virtual => true,
      :virtual    => 'kvm',
      :hostname   => 'host1',
      :selinux    => true
    }
  }
  context "with default" do
    let(:params){
      {
        :folder => '/data',
        :size   => '1G',
        :owner  => '100',
        :group  => '99'
      }
    }
    it { should contain_logical_volume('somedisk').with(
      :ensure        => 'present',
      :volume_group  => 'vdata-host1',
      :size          => '1G',
      :require       => 'Anchor[disks::datavg::finished]',
      :before        => 'Filesystem[/dev/vdata-host1/somedisk]'
    )}
    it { should contain_filesystem("/dev/vdata-host1/somedisk").with(
      :ensure  => 'present',
      :fs_type => 'ext4'
    )}
    it { should contain_file('/data').with(
      :ensure   => 'directory',
      :owner    => '100',
      :group    => '99',
      :mode     => nil
    )}
    it { should contain_mount('/data').with(
      :ensure  => 'mounted',
      :atboot  => true,
      :dump    => 1,
      :pass    => 2,
      :fstype  => 'ext4',
      :options => 'defaults',
      :device  => '/dev/vdata-host1/somedisk',
      :require => [ 'File[/data]', 'Filesystem[/dev/vdata-host1/somedisk]' ]
    )}

    it { should contain_exec('restorecon /data').with(
      :refreshonly => true,
      :subscribe   => 'Mount[/data]',
      :before      => 'Anchor[disks::def_diskmount::somedisk::finished]'
    )}
    it { should contain_disks__mount_owner('/data').with(
      :owner   => '100',
      :group   => '99',
      :mode    => nil,
      :require => 'Mount[/data]',
      :before  => 'Anchor[disks::def_diskmount::somedisk::finished]'
    )}
    it { should contain_anchor('disks::def_diskmount::somedisk::finished').with(
      :before  => 'Anchor[disks::all_mount_setup]'
    )}
  end

  context 'with mode and mount options' do
    let(:facts){
      {
        :is_virtual => true,
        :virtual    => 'kvm',
        :hostname   => 'host1'
      }
    }
    let(:params){
      {
        :folder         => '/data',
        :size           => '11G',
        :owner          => '1001',
        :group          => '991',
        :mode           => '0600',
        :mount_options  => 'defaults,noatime',
        :fs_type        => 'ext3'
      }
    }
    it { should contain_logical_volume('somedisk').with(
      :ensure        => 'present',
      :volume_group  => 'vdata-host1',
      :size          => '11G',
      :require       => 'Anchor[disks::datavg::finished]',
      :before        => 'Filesystem[/dev/vdata-host1/somedisk]'
    )}
    it { should contain_filesystem("/dev/vdata-host1/somedisk").with(
      :ensure  => 'present',
      :fs_type => 'ext3'
    )}
    it { should contain_file('/data').with(
      :ensure   => 'directory',
      :owner    => '1001',
      :group    => '991',
      :mode     => '0600'
    )}
    it { should contain_mount('/data').with(
      :ensure  => 'mounted',
      :atboot  => true,
      :dump    => 1,
      :pass    => 2,
      :fstype  => 'ext3',
      :options => 'defaults,noatime',
      :device  => '/dev/vdata-host1/somedisk',
      :require => [ 'File[/data]', 'Filesystem[/dev/vdata-host1/somedisk]' ]
    )}
    it { should_not contain_exec('restorecon /data') }
    it { should contain_disks__mount_owner('/data').with(
      :owner   => '1001',
      :group   => '991',
      :mode    => '0600',
      :require => 'Mount[/data]',
      :before  => 'Anchor[disks::def_diskmount::somedisk::finished]'
    )}
    it { should contain_anchor('disks::def_diskmount::somedisk::finished').with(
      :before  => 'Anchor[disks::all_mount_setup]'
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
    it { should contain_logical_volume('somedisk').with(
      :ensure        => 'present',
      :volume_group  => 'vdata-host1',
      :size          => '11G',
      :require       => 'Anchor[disks::datavg::finished]',
      :before        => 'Filesystem[/dev/vdata-host1/somedisk]'
    )}
    it { should contain_filesystem("/dev/vdata-host1/somedisk").with(
      :ensure  => 'present',
      :fs_type => 'ext4'
    )}
    it { should_not contain_file('/data') }
    it { should contain_mount('/data').with(
      :ensure  => 'mounted',
      :atboot  => true,
      :dump    => 1,
      :pass    => 2,
      :fstype  => 'ext4',
      :options => 'defaults,noatime',
      :device  => '/dev/vdata-host1/somedisk',
      :require => [ 'File[/data]', 'Filesystem[/dev/vdata-host1/somedisk]' ]
    )}
    it { should contain_disks__mount_owner('/data').with(
      :owner   => '1001',
      :group   => '991',
      :mode    => '0600',
      :require => 'Mount[/data]',
      :before  => 'Anchor[disks::def_diskmount::somedisk::finished]'
    )}
    it { should contain_anchor('disks::def_diskmount::somedisk::finished').with(
      :before  => 'Anchor[disks::all_mount_setup]'
    )}
  end
end

