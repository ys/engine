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
  end
end

# TODO: fork https://github.com/Papipo/mongoid_i18n
module Mongoid
  module I18n
    module ClassMethods
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
            puts "@attributes[name].present? = #{@attributes[name].present?.inspect} / !@attributes[name].is_a?(Hash) #{(!@attributes[name].is_a?(Hash)).inspect}"
            if !@attributes[name].nil? && !@attributes[name].is_a?(Hash)
              @attributes[name] = { ::I18n.default_site_locale.to_s => @attributes[name] }
            end

            puts "value = #{value.inspect} / #{meth}"

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