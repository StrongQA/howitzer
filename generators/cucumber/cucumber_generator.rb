require 'rbconfig'

class CucumberGenerator < RubiGen::Base
  def manifest
    record do |m|
      m.directory 'features'
      m.directory 'step_definitions'
      m.directory 'support'
      m.directory '../tasks'
      m.directory '../config'

      BASEDIRS.each{|path| m.directory path}
      m.template 'common_steps.rb', 'step_definitions/common_steps.rb'
      m.template 'env.rb', 'support/env.rb'
      m.template 'transformers.rb', 'support/transformers.rb'
      m.template 'example.feature', 'example.feature'
      m.template 'cucumber.rake', '../tasks/cucumber.rake'
      m.file 'cucumber.yml', '../config/cucumber.yml'
    end
  end

  protected
  def banner
    <<-EOS
    Integrates Cucumber to the framework
    EOS
  end

  BASEDIRS = %w(
    step_definitions
    support
  )
end