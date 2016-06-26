require File.expand_path(File.join(File.dirname(__FILE__),'../spec_helper'))

describe 'disks::datavg::params', :type => 'class' do
  let(:facts){
    {
      :is_virtual               => true,
      :virtual                  => 'kvm',
      :hostname                 => 'host1',
      :lvm_vg_vdata_host1_pvs => '/dev/sdb1',
    }
  }
  context 'with default params' do
    it { is_expected.to compile.with_all_deps }
  end
end

