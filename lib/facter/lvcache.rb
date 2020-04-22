require 'json'
Facter.add('lvm_cache_vols') do
  confine :lvm_support => true
  setcode do
    output = Facter::Util::Resolution.exec('lvs -S lv_attr=~^C --reportformat json 2>/dev/null')
    if output.nil?
      []
    else
      JSON.load(output)['report'].first['lv'].map{|d| "#{d['vg_name']}-#{d['lv_name']}" }
    end
  end
