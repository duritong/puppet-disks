require File.expand_path(File.join(File.dirname(__FILE__),'../spec_helper'))

describe 'disks::utils', :type => 'class' do

  context 'with default params' do
    it { should contain_file('/usr/local/sbin/init_datavg_disk.sh').with(
      :content => "#!/bin/bash

if [ -z \$1 ]; then
  echo \"Usage: \$0 /dev/disk\"
  exit 1
fi
parted -s \$1 mklabel gpt
parted -s \$1 mkpart -- primary ext4 1 -1
partprobe \$1
",
      :owner   => 'root',
      :group   => 0,
      :mode    => '0700'
    )}
  end
end

