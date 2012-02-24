source 'http://rubygems.org'

group :development, :test do
  gem 'rspec'
  gem 'cucumber'
  # Testing infrastructure
  gem 'guard'
  gem 'guard-rspec'

  if RUBY_PLATFORM =~ /darwin/
    # OS X integration
    gem "ruby_gntp"
    gem "rb-fsevent", "~> 0.4.3.1"
  end
end

gem "nokogiri"

# Specify your gem's dependencies in kindler.gemspec
gemspec
