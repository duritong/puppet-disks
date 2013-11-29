require File.expand_path(File.join(File.dirname(__FILE__),'../spec_helper'))

describe 'disks::datavg', :type => 'class' do

  describe 'with standard' do
    it { expect { subject.call('fail') }.to raise_error(Puppet::Error) }
    # it { should contain_anchor('disks::datavg::finished') }
  end

  describe 'on kvm' do
    let(:facts){
      {
        :virtual    => 'kvm',
        :is_virtual => true,
        :hostname   => 'host1',
      }
    }
    context 'with default params' do

      it { should include_class('disks') }

      it { should contain_disks__pv('/dev/vdb') }
      it { should contain_volume_group('vdata-host1').with(
        :ensure           => 'present',
        :physical_volumes => '/dev/vdb1',
        :createonly       => false,
        :before           => 'Anchor[disks::datavg::finished]'
      )}
      it { should contain_anchor('disks::datavg::finished') }
    end
    context 'with other params' do
      let(:params){
        {
          :disk       => '/dev/sdc',
          :vg         => 'foo',
          :createonly => true
        }
      }
      it { should contain_disks__pv('/dev/sdc') }
      it { should contain_volume_group('foo').with(
        :ensure           => 'present',
        :physical_volumes => '/dev/sdc1',
        :createonly       => true,
        :before           => 'Anchor[disks::datavg::finished]'
      )}
      it { should contain_anchor('disks::datavg::finished') }
    end
  end
end

