source 'https://rubygems.org'
gemspec

unless ENV['TRAVIS']
  gem 'byebug', require: false, platforms: :mri
  gem 'yard',   require: false
end

gem 'hanami-utils', '1.1.0.beta1', require: false, git: 'https://github.com/hanami/utils.git', branch: 'develop'
gem 'haml'

gem 'rubocop', '0.48.0', require: false
gem 'coveralls',         require: false
