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
          options.merge!(:type => LocalizedField, :default => LocalizedField.new)
        end
        super
      end

      protected

      def localized_field?(name)
        # puts "options[:type] = #{options[:type].inspect} / #{(options[:type] == LocalizedField).inspect}"

        # return true if options[:type] == LocalizedField

        # puts "self.localized_fields_list = #{self.localized_fields_list.inspect} / #{meth.inspect}"

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
          if options[:use_default_if_empty] != false # nil or true
            define_method(meth) do
              value = read_attribute(name)
              if value.is_a?(Hash)
                value[::I18n.site_locale.to_s] || value[::I18n.default_site_locale.to_s] rescue ''
              else
                value
              end
            end
          else
            define_method(meth) do
              value = read_attribute(name)
              if value.is_a?(Hash)
                read_attribute(name)[::I18n.site_locale.to_s] rescue ''
              else
                value
              end
            end
          end
          define_method("#{meth}=") do |value|
            # debugger
            # puts "@attributes[name].present? = #{@attributes[name].present?.inspect} / !@attributes[name].is_a?(Hash) #{(!@attributes[name].is_a?(Hash)).inspect}"
            if !@attributes[name].nil? && !@attributes[name].is_a?(Hash)
              @attributes[name] = { ::I18n.default_site_locale.to_s => @attributes[name] }
            end

            # puts "value = #{value.inspect} / #{meth}"

            value = if value.is_a?(Hash)
              (@attributes[name] || {}).merge(value)
            else
              (@attributes[name] || {}).merge(::I18n.site_locale.to_s => value)
            end
            value = value.delete_if { |key, value| value.blank? } if options[:clear_empty_values] != false
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