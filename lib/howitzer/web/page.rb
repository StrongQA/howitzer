require 'singleton'
require 'capybara'
require 'capybara/dsl'
require 'rspec/expectations'
require 'addressable/template'
require 'howitzer/web/page_validator'
require 'howitzer/web/element'
require 'howitzer/exceptions'

module Howitzer
  module Web
    # This class represents single web page. This is parent class for all web pages
    class Page
      UnknownPage = Class.new
      include Singleton
      include Element
      include PageValidator
      include ::RSpec::Matchers
      include ::Capybara::DSL
      extend ::Capybara::DSL

      def self.inherited(subclass)
        subclass.class_eval { include Singleton }
        PageValidator.pages << subclass
      end

      ##
      #
      # Opens web page
      #
      # *Parameters:*
      # * +params+ - Params for url expansion.
      #
      # *Returns:*
      # * +WebPage+ - New instance of current class
      #

      def self.open(params = {})
        url = expanded_url(params)
        log.info "Open #{name} page by '#{url}' url"
        retryable(tries: 2, logger: log, trace: true, on: Exception) do |retries|
          log.info 'Retry...' unless retries.zero?
          visit url
        end
        given
      end

      ##
      #
      # Returns singleton instance of current web page
      #
      # *Returns:*
      # * +WebPage+ - Singleton instance
      #

      def self.given
        wait_for_opened
        instance
      end

      ##
      #
      # Returns current url
      #
      # *Returns:*
      # * +string+ - Current url
      #

      def self.current_url
        page.current_url
      end

      ##
      #
      # Returns body text of html page
      #
      # *Returns:*
      # * +string+ - Body text
      #

      def self.text
        page.find('body').text
      end

      ##
      #
      # Tries to identify current page name or raise error if ambiguous page matching
      #
      # *Returns:*
      # * +string+ - page name
      #

      def self.current_page
        page_list = matched_pages
        if page_list.count.zero?
          UnknownPage
        elsif page_list.count > 1
          log.error AmbiguousPageMatchingError,
                    "Current page matches more that one page class (#{page_list.join(', ')}).\n" \
                    "\tCurrent url: #{current_url}\n\tCurrent title: #{title}"
        elsif page_list.count == 1
          page_list.first
        end
      end

      ##
      #
      # Waits until web page is not opened, or raise error after timeout
      #
      # *Parameters:*
      # * +time_out+ - Seconds that will be waiting for web page to be loaded
      #

      def self.wait_for_opened(timeout = settings.timeout_small)
        end_time = ::Time.now + timeout
        opened? ? return : sleep(0.5) until ::Time.now > end_time
        log.error IncorrectPageError, "Current page: #{current_page}, expected: #{self}.\n" \
                  "\tCurrent url: #{current_url}\n\tCurrent title: #{title}"
      end

      ##
      # Returns expanded page url
      #
      # *Parameters:*
      # * +params+ - Params for url expansion.
      #

      def self.expanded_url(params = {})
        if url_template.nil?
          raise PageUrlNotSpecifiedError, "Please specify url for '#{self}' page. Example: url '/home'"
        end
        "#{parent_url}#{Addressable::Template.new(url_template).expand(params)}"
      end

      class << self
        protected

        ##
        #
        # DSL to specify page url
        #
        # *Parameters:*
        # * +value+ - url pattern, for details please see Addressable gem
        #

        def url(value)
          @url_template = value.to_s
        end

        def root_url(value)
          @root_url = value
        end

        private

        attr_reader :url_template

        def parent_url
          @root_url || Helpers.app_url
        end
      end

      def initialize
        check_validations_are_defined!
        page.driver.browser.manage.window.maximize if settings.maximized_window
      end

      ##
      #
      # Accepts or declines JS alert box by given flag
      #
      # *Parameters:*
      # * +flag+ [TrueClass,FalseClass] - Determines accept or decline alert box
      #

      def click_alert_box(flag)
        if %w(selenium sauce).include? settings.driver
          alert = page.driver.browser.switch_to.alert
          flag ? alert.accept : alert.dismiss
        else
          page.evaluate_script("window.confirm = function() { return #{flag}; }")
        end
      end

      ##
      #
      # Reloads current page
      #

      def reload
        log.info "Reload '#{current_url}'"
        visit current_url
      end

      ##
      #
      # Returns Page title
      #
      # *Returns:*
      # * +string+ - Page title
      #

      def title
        page.title
      end
    end
  end
end
