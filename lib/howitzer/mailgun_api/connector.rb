require 'singleton'
require 'howitzer/mailgun_api/client'
require 'howitzer/exceptions'

module Howitzer
  module MailgunApi
    # This class represent connector to Mailgun service
    class Connector
      include Singleton

      attr_reader :api_key

      def client(api_key = settings.mailgun_key)
        check_api_key(api_key)
        if @api_key == api_key && @api_key
          @client
        else
          @api_key = api_key
          @client = Client.new(@api_key)
        end
      end

      def domain
        @domain || change_domain
      end

      def change_domain(domain_name = settings.mailgun_domain)
        @domain = domain_name
      end

      private

      def check_api_key(api_key)
        log.error InvalidApiKeyError, 'Api key can not be blank' if api_key.blank?
      end
    end
  end
end
