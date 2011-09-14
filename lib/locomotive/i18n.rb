# require 'ruby-debug'
## patches for the i18n support (aka multi languages support)
require 'i18n'

module I18n
  class Config
    def site_locale
      @site_locale ||= default_site_locale
    end

    def site_locale=(site_locale)
      @site_locale = site_locale.to_sym rescue nil
    end

    def default_site_locale
      @@default_site_locale ||= :en
    end

    def default_site_locale=(site_locale)
      @@default_site_locale = site_locale.to_sym rescue nil
    end
  end

  class << self
    # Write methods which delegates to the configuration object
    %w(site_locale default_site_locale).each do |method|
      module_eval <<-DELEGATORS, __FILE__, __LINE__ + 1
        def #{method}
          config.#{method}
        end

        def #{method}=(value)
          config.#{method} = (value)
        end
      DELEGATORS
    end

    # Executes block with given I18n.site_locale set.
    def with_site_locale(tmp_locale = nil)
      if tmp_locale
        current_locale    = self.site_locale
        self.site_locale  = tmp_locale
      end
      yield
    ensure
      self.site_locale = current_locale if tmp_locale
    end
  end
end

## CARRIERWAVE ##
require 'carrierwave/orm/mongoid'

module CarrierWave
  module Mongoid
    def mount_uploader_with_localization(column, uploader=nil, options={}, &block)
      mount_uploader_without_localization(column, uploader, options, &block)

      define_method(:read_uploader) { |name| self.send(name.to_sym) }
      define_method(:write_uploader) { |name, value| self.send(:"#{name.to_sym}=", value) }
    end

    alias_method_chain :mount_uploader, :localization
  end
end

## MONGOID-I18n ##

# TODO: fork https://github.com/Papipo/mongoid_i18n

module Mongoid
  module I18n
    class LocalizedField < Hash

      attr_accessor :type

      def initialize(type = nil)
        self.type = type || Object
        super nil
      end

      def [](key)
        self.type.set(super(key))
      end

      def []=(key, value)
        super(key, self.type.set(value))
      end

      def merge(other_hash, &block)
        # puts "merging #{other_hash.inspect}"
        converted_hash = {}
        other_hash.each { |k, v| converted_hash[k] = self.type.set(v) }
        # puts "converted_hash = #{converted_hash.inspect}"
        super(converted_hash, &block)
      end

    end
  end
end

# DIRTY MONKEY PATCHING BEFORE THE REFACTORING
module Mongoid
  module Criterion
    class Selector< Hash
      def []=(key, value)
        key = "#{key}.#{::I18n.site_locale}" if fields[key.to_s].try(:type) == Mongoid::I18n::LocalizedField
        super
      end
    end
  end

  module I18n

    included do
      cattr_accessor :localized_fields_list
    end

    module ClassMethods

      def localized_fields(*args)
        self.localized_fields_list = [*args].collect
      end

      def field(name, options = {})
        if localized_field?(name)
          options.merge!(:type => LocalizedField, :default => LocalizedField.new(options[:type]))
        end
        super
      end

      protected

      def localized_field?(name)
        (self.localized_fields_list || []).any? do |rule|
          case rule
          when String, Symbol then name.to_s == rule.to_s
          when Regexp then !(name.to_s =~ rule).nil?
          else
            false
          end
        end.tap do |result|
          # options[:type] = LocalizedField if result

          # puts "#{name.inspect}... localized ? #{result.inspect}"
        end
      end

      def create_accessors(name, meth, options = {})
        if options[:type] == LocalizedField

          if options[:use_default_if_empty] != false # either nil or true
            define_method(meth) do
              value = read_attribute(name)
              if value.is_a?(Hash)
                converted_value = options[:default].merge(value)

                value = converted_value[::I18n.site_locale.to_s]

                value.to_s.empty? ? converted_value[::I18n.default_site_locale.to_s] : value
              else
                value
              end
            end
          else
            define_method(meth) do
              value = read_attribute(name)
              if value.is_a?(Hash)
                converted_value = options[:default].merge(value)
                options[:default].merge(value)[::I18n.site_locale.to_s]
              else
                value
              end
            end
          end

          define_method("#{meth}=") do |value|
            if !@attributes[name].nil? && !@attributes[name].is_a?(Hash)
              # existing value but not localized yet
              old_value = @attributes[name]
              @attributes[name] = options[:default].merge(::I18n.default_site_locale.to_s => old_value)
            end

            @attributes[name] ||= options[:default]

            @attributes[name] = options[:default].merge(@attributes[name]) unless @attributes[name].is_a?(LocalizedField)

            value = if value.is_a?(Hash)
              @attributes[name].merge(value)
            else
              @attributes[name].merge(::I18n.site_locale.to_s => value)
            end

            value = value.delete_if { |key, value| value.to_s.empty? } if options[:clear_empty_values] != false

            write_attribute(name, value)
          end

          define_method("#{meth}_translations") { read_attribute(name) }

          if options[:clear_empty_values] != false
            define_method("#{meth}_translations=") { |value| write_attribute(name, value.delete_if { |key, value| value.blank? }) }
          else
            define_method("#{meth}_translations=") { |value| write_attribute(name, value) }
          end

        else
          super
        end
      end
    end
  end
end