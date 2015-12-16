require File.expand_path(File.join(File.dirname(__FILE__),'../spec_helper'))

describe 'disks', :type => 'class' do
  context 'with default params' do
    it { should compile.with_all_deps }
  end
end

