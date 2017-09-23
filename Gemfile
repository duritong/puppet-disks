source 'https://rubygems.org'

if ENV.key?('PUPPET_VERSION')
  puppetversion = "~> #{ENV['PUPPET_VERSION']}"
else
  puppetversion = ['>= 5.2']
end

if RUBY_VERSION == '1.8.7'
  gem 'i18n', '~> 0.6.11'
  gem 'activesupport', '~> 3.2'
  gem 'highline', '~> 1.6.21'
  gem 'librarian-puppet', '~> 1.0.0'
  gem 'rspec', '~> 3.1.0'
  gem 'rake', '< 11'
else
  gem 'librarian-puppet', '>=0.9.10'
  gem 'rake'
end

gem 'puppet', puppetversion
gem 'puppet-lint', '>=0.3.2'
gem 'puppetlabs_spec_helper', '>=0.2.0'
