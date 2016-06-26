require File.expand_path(File.join(File.dirname(__FILE__),'../spec_helper'))

describe 'disks::utils', :type => 'class' do

  context 'with default params' do
    it { is_expected.to contain_file('/usr/local/sbin/init_datavg_disk.sh').with(
      :source  => 'puppet:///modules/disks/utils/init_datavg_disk.sh',
      :owner   => 'root',
      :group   => 0,
      :mode    => '0700'
    )}
  end
end

