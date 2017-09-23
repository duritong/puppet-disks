source 'https://rubygems.org'

if ENV.key?('PUPPET_VERSION')
  puppetversion = "~> #{ENV['PUPPET_VERSION']}"
else
  puppetversion = ['>= 5.2']
end

gem 'puppet', puppetversion
gem 'librarian-puppet'
gem 'rake'
gem 'puppet-lint'
gem 'puppetlabs_spec_helper'
