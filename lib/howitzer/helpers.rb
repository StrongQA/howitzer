require 'howitzer/exceptions'

CHECK_YOUR_SETTINGS_MSG = "Please check your settings"

def sauce_driver?
  log.error Howitzer::DriverNotSpecifiedError, CHECK_YOUR_SETTINGS_MSG if settings.driver.nil?
  settings.driver.to_sym == :sauce
end

def testingbot_driver?
  log.error Howitzer::DriverNotSpecifiedError, CHECK_YOUR_SETTINGS_MSG if settings.driver.nil?
  settings.driver.to_sym == :testingbot
end

def selenium_driver?
  log.error Howitzer::DriverNotSpecifiedError, CHECK_YOUR_SETTINGS_MSG if settings.driver.nil?
  settings.driver.to_sym == :selenium
end

def phantomjs_driver?
  log.error Howitzer::DriverNotSpecifiedError, CHECK_YOUR_SETTINGS_MSG if settings.driver.nil?
  settings.driver.to_sym == :phantomjs
end

def remote_browser_driver?
  log.error Howitzer::DriverNotSpecifiedError, CHECK_YOUR_SETTINGS_MSG if settings.driver.nil?
  settings.driver.to_sym == :remote_browser
end

def ie_browser?
  ie_browsers = [:ie, :iexplore]
  if sauce_driver?
    log.error Howitzer::SlBrowserNotSpecifiedError, CHECK_YOUR_SETTINGS_MSG if settings.sl_browser_name.nil?
    ie_browsers.include?(settings.sl_browser_name.to_sym)
  elsif testingbot_driver?
    log.error Howitzer::TbBrowserNotSpecifiedError, CHECK_YOUR_SETTINGS_MSG if settings.tb_browser_name.nil?
    ie_browsers.include?(settings.tb_browser_name.to_sym)
  elsif selenium_driver? || remote_browser_driver?
    log.error Howitzer::SelBrowserNotSpecifiedError, CHECK_YOUR_SETTINGS_MSG if settings.sel_browser.nil?
    ie_browsers.include?(settings.sel_browser.to_sym)
  end
end

def ff_browser?
  ff_browsers = [:ff, :firefox]
  if sauce_driver?
    log.error Howitzer::SlBrowserNotSpecifiedError, CHECK_YOUR_SETTINGS_MSG if settings.sl_browser_name.nil?
    ff_browsers.include?(settings.sl_browser_name.to_sym)
  elsif testingbot_driver?
    log.error Howitzer::TbBrowserNotSpecifiedError, CHECK_YOUR_SETTINGS_MSG if settings.tb_browser_name.nil?
    ff_browsers.include?(settings.tb_browser_name.to_sym)
  elsif selenium_driver? || remote_browser_driver?
    log.error Howitzer::SelBrowserNotSpecifiedError, CHECK_YOUR_SETTINGS_MSG if settings.sel_browser.nil?
    ff_browsers.include?(settings.sel_browser.to_sym)
  end
end


def chrome_browser?
  chrome_browser = :chrome
  if sauce_driver?
    log.error Howitzer::SlBrowserNotSpecifiedError, CHECK_YOUR_SETTINGS_MSG if settings.sl_browser_name.nil?
    settings.sl_browser_name.to_sym == chrome_browser
  elsif testingbot_driver?
    log.error Howitzer::TbBrowserNotSpecifiedError, CHECK_YOUR_SETTINGS_MSG if settings.tb_browser_name.nil?
    settings.tb_browser_name.to_sym == chrome_browser
  elsif selenium_driver? || remote_browser_driver?
    log.error Howitzer::SelBrowserNotSpecifiedError, CHECK_YOUR_SETTINGS_MSG if settings.sel_browser.nil?
    settings.sel_browser.to_sym == chrome_browser
  end
end


##
#
# Returns application url including base authentication (if specified in settings)
#

def app_url                         
  prefix = settings.app_base_auth_login.blank? ? '' : "#{settings.app_base_auth_login}:#{settings.app_base_auth_pass}@"
  app_base_url prefix
end

##
# Returns application url without base authentication by default
#
# *Parameters:*
# * +prefix+ - Sets base authentication prefix (defaults to: nil)
#

def app_base_url(prefix=nil)
  "#{settings.app_protocol || 'http'}://#{prefix}#{settings.app_host}"
end

# *Parameters:*
# * +time_in_numeric+ - Number of seconds
#

def duration(time_in_numeric)
  secs = time_in_numeric.to_i
  mins = secs / 60
  hours = mins / 60
  if hours > 0
    "[#{hours}h #{mins % 60}m #{secs % 60}s]"
  elsif mins > 0
    "[#{mins}m #{secs % 60}s]"
  elsif secs >= 0
    "[0m #{secs}s]"
  end
end

##
#
# Evaluates given value
#
# *Parameters:*
# * +value+ - Value to be evaluated
#

def ri(value)
  raise value.inspect
end

class String

  ##
  #
  # Delegates WebPage.open method. Useful in cucumber step definitions
  #
  # *Parameters:*
  # * +*args+ - Url to be opened
  #

  def open(*args)
    as_page_class.open(*args)
  end

  ##
  #
  # Returns page instance
  #

  def given
    as_page_class.given
  end

  def wait_for_opened
    as_page_class.wait_for_opened
  end

  ##
  #
  # Returns page class
  #

  def as_page_class
    as_class('Page')
  end

  def as_email_class
    as_class('Email')
  end

  private
  def as_class(type)
    "#{self.gsub(/\s/, '_').camelize}#{type}".constantize
  end
end
