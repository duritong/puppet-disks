require File.expand_path(File.join(File.dirname(__FILE__),'../spec_helper'))

describe 'disks::datavg::params', :type => 'class' do
  let(:facts){
    {
      :virtual => 'kvm',
    }
  }
  context 'with default params' do
    it { should compile.with_all_deps }
  end
end

