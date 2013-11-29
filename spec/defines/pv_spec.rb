require File.expand_path(File.join(File.dirname(__FILE__),'../spec_helper'))

describe 'disks::pv', :type => 'define' do
  let(:title) { '/dev/sdb' }
  context "with default_values" do

    it { should contain_class('disks::utils') }

    it { should contain_exec('make_/dev/sdb').with(
      :command  => '/usr/local/sbin/init_datavg_disk.sh /dev/sdb',
      :unless   => 'test -b /dev/sdb1',
      :notify   => 'Exec[partprobe_/dev/sdb]',
      :require  => 'File[/usr/local/sbin/init_datavg_disk.sh]'
    )}

    it { should contain_exec('partprobe_/dev/sdb').with(
      :command     => 'partprobe /dev/sdb',
      :refreshonly => true
    )}

    it { should contain_physical_volume('/dev/sdb1').with(
      :ensure  => 'present',
      :require => 'Exec[partprobe_/dev/sdb]'
    )}
  end
end
