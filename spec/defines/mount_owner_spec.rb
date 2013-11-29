require File.expand_path(File.join(File.dirname(__FILE__),'../spec_helper'))

describe 'disks::mount_owner', :type => 'define' do
  let(:title) { '/var/log/munin' }
  context "with default_values" do
    let(:params){
      {
        :owner => '100',
        :group => '99'
      }
    }
    it { should contain_exec("ensure_mount_owner_on_/var/log/munin").with(
      :command     => "chown 100:99 /var/log/munin",
      :refreshonly => true,
      :subscribe   => 'Mount[/var/log/munin]'
    )}
    it { should_not contain_exec("ensure_mount_mode_on_/var/log/munin") }
  end
  
  context 'with mode' do
    let(:params){
      {
        :owner => '100',
        :group => '99',
        :mode  => '0644'
      }
    }
    it { should contain_exec("ensure_mount_owner_on_/var/log/munin").with(
      :command     => "chown 100:99 /var/log/munin",
      :refreshonly => true,
      :subscribe   => 'Mount[/var/log/munin]'
    )}
    it { should contain_exec("ensure_mount_mode_on_/var/log/munin").with(
      :command     => "chmod 0644 /var/log/munin",
      :refreshonly => true,
      :subscribe   => 'Mount[/var/log/munin]'
    ) }
  end
end

