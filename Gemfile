source 'http://rubygems.org'

group :development, :test do
	gem 'rspec'
  # Testing infrastructure
  gem 'guard'
  gem 'guard-rspec'

  if RUBY_PLATFORM =~ /darwin/
    # OS X integration
    gem "ruby_gntp"
    gem "rb-fsevent", "~> 0.4.3.1"
  end
end

gem "ruby-readability",:git=>'https://github.com/iterationlabs/ruby-readability.git', :require => 'readability'
gem 'mini_magick'

# Specify your gem's dependencies in kindler.gemspec
gemspec
