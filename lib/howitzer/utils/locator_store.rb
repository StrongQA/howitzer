#The following are locator aliases:
#
#1) locator
#Type: :css(by default), :xpath
#Method example: find, all, first
#
#2) link_locator
#Type: id, text
#Method example: click_link, find_link
#
#3) button_locator
#Type: id, name, value
#Method example: click_button, find_button
#
#4) field_locator
#Type: name, id, text
#Method example: find_field, fill_in


module LocatorStore
  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    class BadLocatorParamsError < StandardError; end
    class LocatorNotSpecifiedError < StandardError; end

    ##
    #
    # Add css or xpath locator in memory.
    # Also locator can be set by lambda expression. For example: lambda{|name|{xpath: ".//a[@id='#{name}']"}}
    # @param name [Symbol]                        Locator name
    # @param params [String,Hash]                 String for css locator or hash with :xpath key and string value for xpath locator
    #

    def add_locator(name, params)
      add_locator_by_type(:base, name, params)
    end

    ##
    #
    # Add locator for link in memory. Link can be found by: id, text
    # Capybara methods that can work with this locator type are: click_link, find_link
    # @param name [Symbol]                        Locator name
    # @param params [String]                      ID or text of link
    #

    def add_link_locator(name, params)
      add_locator_by_type(:link, name, params)
    end

    ##
    #
    # Add locator for field in memory. Field can be found by: name, id, text
    # Capybara methods that can work with this locator type are: find_field, fill_in
    # @param name [Symbol]                        Locator name
    # @param params [String]                      Name, ID or text of field
    #

    def add_field_locator(name, params)
      add_locator_by_type(:field, name, params)
    end

    ##
    #
    # Add locator for button in memory. Button can be found by: id, name, value
    # Capybara methods that can work with this locator type are: click_button, find_button
    # @param name [Symbol]                        Locator name
    # @param params [String]                      Name, ID or value
    #
    def add_button_locator(name, params)
      add_locator_by_type(:button, name, params)
    end

    ##
    #
    # Take css or xpath locator from memory by name
    # @param name [Symbol]                        Locator name
    #

    def locator(name)
      locator_by_type(:base, name)
    end

    ##
    #
    # Take link locator from memory by name
    # @param name [Symbol]                        Locator name
    #

    def link_locator(name)
      locator_by_type(:link, name)
    end

    ##
    #
    # Take field locator from memory by name
    # @param name [Symbol]                        Locator name
    #

    def field_locator(name)
      locator_by_type(:field, name)
    end

    ##
    #
    # Take button locator from memory be name
    # @param name [Symbol]                        Locator name
    #

    def button_locator(name)
      locator_by_type(:button, name)
    end

    ##
    #
    # Get locator set by lambda.
    # For example: find(apply(locator(:locator_name), 'register')).click
    # @param locator [LocatorStore]               Locator set with lambda expression
    # @param values [String,Numeric]              Arguments that should be matched lambda expression params
    #

    def apply(locator, *values)
      locator.call(*values).to_a.flatten
    end

    protected

    def parent_locator(type, name)
      if !@locators.nil? && @locators.key?(self.name) && @locators[self.name].key?(type) && @locators[self.name][type].key?(name)
        @locators[self.name][type][name]
      else
        self.superclass.parent_locator(type, name) unless self.superclass == Object
      end
    end

    private

    def locator_by_type(type, name)
      locator = parent_locator(type, name)
      raise(LocatorNotSpecifiedError, name) if locator.nil?
      locator
    end

    def add_locator_by_type(type, name, params)
      @locators ||= {}
      @locators[self.name] ||= {}
      @locators[self.name][type] ||= {}
      raise BadLocatorParamsError, args.inspect if params.nil? || (!params.is_a?(Proc) && params.empty?)
      case params.class.name
        when 'Hash'
          @locators[self.name][type][name] = [params.keys.first.to_sym, params.values.first.to_s]
        when 'Proc'
          @locators[self.name][type][name] = params
        else
          @locators[self.name][type][name] = params.to_s
      end
    end
  end

  def locator(name)
    self.class.locator(name)
  end

  def link_locator(name)
    self.class.link_locator(name)
  end

  def field_locator(name)
    self.class.field_locator(name)
  end

  def button_locator(name)
    self.class.button_locator(name)
  end

  def apply(locator, *values)
    self.class.apply(locator, *values)
  end
end