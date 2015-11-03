require_relative '../base_generator'

module Howitzer
  # This class responsible for page object pattern generation
  class PagesGenerator < BaseGenerator
    def manifest
      { files:
        [
          { source: 'example_page.rb', destination: 'pages/example_page.rb' },
          { source: 'example_menu.rb', destination: 'pages/example_menu.rb' }
        ]
      }
    end

    protected

    def banner
      <<-EOS
  * PageOriented pattern structure generation ...
      EOS
    end
  end
end
