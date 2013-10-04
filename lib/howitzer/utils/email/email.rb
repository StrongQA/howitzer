require 'rspec/matchers'
require 'howitzer/utils/email/mail_client'

# Email class works with Mailgun and used for handling with email box.
# Each class inherited from +Email+ refers only to *one* message into email box.
# This could be useful when you need to test notifications via email or confirmations which are sent to email.

 class Email
  include RSpec::Matchers

  ##
  #
  # Refers to recepient address
  #

  attr_reader :recipient_address

  ##
  #
  # Create new email with +message+
  #

  def initialize(message)
    expect(message.subject).to include(self.class::SUBJECT)
    @recipient_address = ::Mail::Address.new(message.to.first)
    @message = message
  end

  ##
  #
  # Search mail by +recepient+
  #

  def self.find_by_recipient(recipient)
    find(recipient, self::SUBJECT)
  end

  ##
  #
  # Search mail by +recepient+ and +subject+.
  #

  def self.find(recipient, subject)
    messages = MailClient.by_email(recipient).find_mail do |mail|
      /#{Regexp.escape(subject)}/ === mail.subject && mail.to == [recipient]
    end

    if messages.first.nil?
      log.error "#{self} was not found (recipient: '#{recipient}')"
      return   # TODO check log.error raises error
    end
    new(messages.first)
  end

  ##
  #
  # Return email message.
  #

  def plain_text_body
    get_mime_part(@message, 'text/plain').to_s
  end

  ##
  #
  # Allows to get email attachment
  # TODO parameters?
  #
  #
  def get_mime_part(part, type)
    return part.body if part["content-type"].to_s =~ %r!#{type}!
    # Recurse the multi-parts
    part.parts.each do |sub_part|
      r = get_mime_part(sub_part, type)
      return r if r
    end
    nil
  end

  protected :get_mime_part

end