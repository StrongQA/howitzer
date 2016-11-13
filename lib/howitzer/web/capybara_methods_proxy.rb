require 'capybara'

module Howitzer
  module Web
    # This module proxies required original capybara methods to recipient
    module CapybaraMethodsProxy
      PROXIED_CAPYBARA_METHODS = Capybara::Session::SESSION_METHODS +
                                 Capybara::Session::MODAL_METHODS +
                                 [:driver, :text]

      # Capybara form dsl methods are not compatible with page object pattern and Howitzer gem.
      # Instead of including Capybara::DSL module, we proxy most interesting Capybara methods and
      # prevent using extra methods which can potentially broke main principles and framework concept
      PROXIED_CAPYBARA_METHODS.each do |method|
        define_method(method) { |*args, &block| Capybara.current_session.send(method, *args, &block) }
      end

      # Accepts or declines JS alert box by given flag
      # @param flag [Boolean] Determines accept or decline alert box

      def click_alert_box(flag)
        if %w(selenium sauce).include? Howitzer.driver
          alert = driver.browser.switch_to.alert
          flag ? alert.accept : alert.dismiss
        else
          evaluate_script("window.confirm = function() { return #{flag}; }")
        end
      end

      private

      def capybara_scopes
        @_scopes ||= [Capybara.current_session]
      end
    end
  end
end
