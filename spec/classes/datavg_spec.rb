require File.expand_path(File.join(File.dirname(__FILE__),'../spec_helper'))

describe 'disks::datavg', :type => 'class' do
  describe 'on kvm' do
    let(:facts){
      {
        :virtual    => 'kvm',
        :is_virtual => true,
        :hostname   => 'host1',
      }
    }
    context 'with default params' do

      it { should contain_class('disks') }

      it { should contain_disks__pv('/dev/vdb').with(
        :before => 'Volume_group[vdata-host1]',
      ) }
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
          :disks      => ['/dev/sdc'],
          :vg         => 'foo',
          :createonly => true
        }
      }
      it { should contain_disks__pv('/dev/sdc').with(
        :before => 'Volume_group[foo]',
      ) }
      it { should contain_volume_group('foo').with(
        :ensure           => 'present',
        :physical_volumes => '/dev/sdc1',
        :createonly       => true,
        :before           => 'Anchor[disks::datavg::finished]'
      )}
      it { should contain_anchor('disks::datavg::finished') }
    end
    context 'with default params but other disk' do
      let(:facts){
        {
          :virtual                => 'kvm',
          :is_virtual             => true,
          :hostname               => 'host1',
          :lvm_vg_vdata_host1_pvs => '/dev/vdc1',
        }
      }
      it { should contain_class('disks') }

      it { should_not contain_disks__pv('/dev/vdb') }
      it { should_not contain_disks__pv('/dev/vdc') }
      it { should contain_volume_group('vdata-host1').with(
        :ensure           => 'present',
        :physical_volumes => '/dev/vdc1',
        :createonly       => false,
        :before           => 'Anchor[disks::datavg::finished]'
      )}
    end
  end
end

