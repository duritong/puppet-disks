require File.expand_path(File.join(File.dirname(__FILE__),'../spec_helper'))

describe 'disks::datavg', :type => 'class' do
  describe 'on kvm' do
    let(:default_facts){
      {
        :virtual                => 'kvm',
        :is_virtual             => true,
        :hostname               => 'host1',
      }
    }
    let(:facts){
      default_facts
    }
    context 'with default params' do

      it { is_expected.to contain_class('disks') }

      it { is_expected.to contain_disks__pv('/dev/vdb').that_comes_before('Volume_group[vdata-host1]')}
      it { is_expected.to contain_volume_group('vdata-host1').with(
        :ensure           => 'present',
        :physical_volumes => ['/dev/vdb'],
        :createonly       => false,
        :before           => 'Anchor[disks::datavg::finished]'
      )}
      it { is_expected.to contain_anchor('disks::datavg::finished') }
    end
    context 'with other params' do
      let(:params){
        {
          :disks      => ['/dev/sdc'],
          :vg         => 'foo',
          :createonly => true
        }
      }
      it { is_expected.to contain_disks__pv('/dev/sdc').with(
        :before => 'Volume_group[foo]'
      ) }
      it { is_expected.to contain_volume_group('foo').with(
        :ensure           => 'present',
        :physical_volumes => ['/dev/sdc'],
        :createonly       => true,
        :before           => 'Anchor[disks::datavg::finished]'
      )}
      it { is_expected.to contain_anchor('disks::datavg::finished') }
    end
    context 'with default params but other disk' do
      let(:facts){
        default_facts.merge({
          :lvm_vg_vdata_host1_pvs => '/dev/vdc1',
        })
      }
      it { is_expected.to contain_class('disks') }

      it { is_expected.to_not contain_disks__pv('/dev/vdb') }
      it { is_expected.to_not contain_disks__pv('/dev/vdc') }
      it { is_expected.to contain_volume_group('vdata-host1').with(
        :ensure           => 'present',
        :physical_volumes => ['/dev/vdc1'],
        :createonly       => false,
        :before           => 'Anchor[disks::datavg::finished]'
      )}
    end
  end
end

