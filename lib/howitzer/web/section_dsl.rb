module Howitzer
  module Web
    # This module combines section dsl methods
    module SectionDsl
      def self.included(base) #:nodoc:
        base.extend(ClassMethods)
      end

      def capybara_context
        raise NotImplementedError, "Please define 'capybara_context' method for class holder"
      end

      # This module holds section dsl class methods
      module ClassMethods
        # This class is for private usage only
        class SectionScope
          attr_accessor :section_class

          def initialize(name, *args, &block)
            @args = args
            self.section_class =
              if block
                Class.new(Howitzer::Web::AnonymousSection)
              else
                "#{name}_section".classify.constantize
              end
            instance_eval(&block) if block_given?
          end

          def element(*args)
            section_class.send(:element, *args)
          end

          def section(name, *args, &block)
            section_class.send(:section, name, *args, &block)
          end

          def finder_args
            @finder_args ||= begin
              return @args if @args.present?
              section_class.default_finder_args || raise(ArgumentError, 'Missing finder arguments')
            end
          end
        end

        protected

        # TODO: describe me
        #
        def section(name, *args, &block)
          scope = SectionScope.new(name, *args, &block)
          define_section_method(scope.section_class, name, scope.finder_args)
          define_sections_method(scope.section_class, name, scope.finder_args)
          define_has_section_method(name, scope.finder_args)
          define_has_no_section_method(name, scope.finder_args)
        end

        private

        def define_section_method(klass, name, args)
          define_method("#{name}_section") do
            klass.new(self, capybara_context.find(*args))
          end
        end

        def define_sections_method(klass, name, args)
          define_method("#{name}_sections") do
            capybara_context.all(*args).map { |el| klass.new(self, el) }
          end
        end

        def define_has_section_method(name, args)
          define_method("has_#{name}_section?") do
            capybara_context.has_selector?(*args)
          end
        end

        def define_has_no_section_method(name, args)
          define_method("has_no_#{name}_section?") do
            capybara_context.has_no_selector?(*args)
          end
        end
      end
    end
  end
end

require 'howitzer/web/anonymous_section'
