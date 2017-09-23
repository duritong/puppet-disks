require File.expand_path(File.join(File.dirname(__FILE__),'../spec_helper'))

describe 'disks::pv', :type => 'define' do
  let(:title) { '/dev/sdb' }
  let(:default_facts){
    {
      :is_virtual               => true,
      :virtual                  => 'kvm',
      :hostname                 => 'host1',
      :lvm_vg_vdata_host1_pvs => '/dev/sdb1',
    }
  }
  let(:facts){ default_facts }
  context "with default_values" do

    it { should_not contain_class('disks::utils') }

    it { should_not contain_exec('make_/dev/sdb') }

    it { should_not contain_exec('partprobe_/dev/sdb') }

    it { should contain_physical_volume('/dev/sdb').with(
      :ensure  => 'present',
    )}
  end
  context "with partition" do
    let(:params) {
      {
        :force_part => true
      }
    }

    it { should contain_class('disks::utils') }

    it { should contain_exec('make_/dev/sdb').with(
      :command  => '/usr/local/sbin/init_datavg_disk.sh /dev/sdb',
      :unless   => 'test -b /dev/sdb1',
      :notify   => 'Exec[partprobe_/dev/sdb]',
      :require  => 'File[/usr/local/sbin/init_datavg_disk.sh]'
    )}

    it { should contain_exec('partprobe_/dev/sdb').with(
      :command     => 'partprobe /dev/sdb',
      :refreshonly => true,
      :before      => 'Physical_volume[/dev/sdb1]',
    )}

    it { should contain_physical_volume('/dev/sdb1').with(
      :ensure  => 'present',
    )}
  end
end
