require 'rubygems'
require 'bundler/setup'
require 'simplecov'
require 'tmpdir'
require 'rubygems'
require 'bundler/setup'
require 'simplecov'
require 'capybara'
require 'json'
require 'capybara/dsl'

SimpleCov.start do
  add_filter "/spec/"
  add_filter '/config/'
  add_filter do |source_file|
    source_file.lines.count < 5
  end
  add_group "generators", "/generators"
  add_group "lib", "/lib"
end

Dir[File.join(File.dirname(__FILE__), 'support', '**', '*.rb')].each{ |f| require f }

RSpec.configure do |config|
  config.include GeneratorHelper
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
  config.mock_with :rspec do |c|
    c.syntax = :expect
  end
end

def project_path
  File.expand_path(File.join(File.dirname(__FILE__), '..'))
end

def lib_path
  File.join(project_path, 'lib')
end

def generators_path
  File.join(project_path, 'generators')
end
